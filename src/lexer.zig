const std = @import("std");

pub const Token = union(enum) {
    illegal,
    eof,
    token: []const u8,

    // Control Operators
    @"and",// &
    dand, // &&
    lparen, // (
    rparen, // )
    pipe, // |
    dpipe, // ||
    semi, // ;
    dsemi, // ;;
    new_line, // \n

    // Redirection operators
    less, // <
    dless, // <<
    great, // >
    dgreat, // >>
    less_and, // <&
    great_and, // >&
    less_great, // <>
    dless_dash, // <<-
    clobber, // >|

    // Quoting
    bslash, // \
    quote, // '
    dquote, // "

    // Keywords
    If,
    Then,
    Else,
    Elif,
    Fi,
    Do,
    Done,
    Case,
    Esac,
    While,
    Until,
    For,
    In,
    LBrace, // {
    Rbrace, // }
    Bang, // !

    Null,

    fn isKeyword(word: []const u8) ?Token {
        const map = std.StaticStringMap(Token, .{
            .{ "if", .If },
            .{ "then", .Then },
            .{ "else", .Else },
            .{ "elif", .Elif },
            .{ "fi", .Fi },
            .{ "do", .Do },
            .{ "done", .Done },
            .{ "case", .Case },
            .{ "esac", .Esac },
            .{ "while", .While },
            .{ "until", .Until },
            .{ "for", .For },
            .{ "in", .In },
            .{ "{", .LBrace },
            .{ "}", .Rbrace },
            .{ "!", .Bang },
        });

        return map.get(word);
    }
};

pub const Lexer = struct {
    const Self = @This();
    
    readPos: usize = 0,
    pos: usize = 0,
    ch: u8 = 0,
    input: []const u8,

    pub fn init(input: []const u8) Self {
        var lex = Self{
            .input = input,
        };

        lex.readChar();

        return lex;
    }

    pub fn has_tokens(self: *Self) bool {
        return self.ch != 0;
    }

    pub fn nextToken(self: *Self) Token {
        const token: Token = switch (self.ch) {
            '\\' => .bslash,
            '\'' => .quote,
            '"' => .dquote,
            '&' => blk: {
                if (self.peekChar() == '&') {
                    self.readChar();
                    break :blk .dand;
                }

                break :blk .@"and";
            },
            '(' => .lparen,
            ')' => .rparen,
            '|' => blk: {
                if (self.peekChar() == '|') {
                    self.readChar();
                    break :blk .dpipe;
                }

                break :blk .pipe;
            },
            ';' => blk: {
                if (self.peekChar() == ';') {
                    self.readChar();
                    break :blk .dsemi;
                } else {
                    break :blk .semi;
                }
            },
            '\n' => .new_line,
            '<' => blk: {
                const peek = self.peekChar();

                if (peek == '&') {
                    self.readChar();
                    break :blk .less_and;
                } else if (peek == '>') {
                    self.readChar();
                    break :blk .less_great;
                } else if (peek == '<') {
                    self.readChar();

                    if (self.peekChar() == '-') {
                        self.readChar();
                        break :blk .dless_dash;
                    } else {
                        break :blk .dless;
                    }
                } else {
                    break :blk .less;
                }
            },
            '>' => blk: {
                if (self.peekChar() == '>') {
                    self.readChar();
                    break :blk .dgreat;
                } else if (self.peekChar() == '&') {
                    self.readChar();
                    break :blk .great_and;
                } else if (self.peekChar() == '|') {
                    self.readChar();
                    break :blk .clobber;
                } else {
                    break :blk .great;
                }
            },
            0 => .eof,
            else => blk: {
                std.debug.print("Invalid character: {}", .{ self.ch });
                break :blk .illegal;
            }
        };

        self.readChar();
        return token;
    }

    fn peekChar(self: *Self) u8 {
        if (self.readPos >= self.input.len) {
            return 0;
        } else {
            return self.input[self.readPos];
        }
    }

    fn readChar(self: *Self) void {
        if (self.readPos >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.readPos];
        }

        self.pos = self.readPos;
        self.readPos += 1;
    }

    fn skip_whitespace(self: *Self) void {
        while (std.ascii.isWhitespace(self.ch)) {
            self.readChar();
        }
    }
};

test "Lexer" {
    const input = "<>>><<";
    const expectedTokens = [3]Token{ .less_great, .dgreat, .dless };

    var lex = Lexer.init(input);


    for (expectedTokens) |token| {
        const tok = lex.nextToken();
        // std.debug.print("Tokens: {any}, {any}\n", .{ token, tok });

        try std.testing.expectEqualDeep(token, tok);
    }
}