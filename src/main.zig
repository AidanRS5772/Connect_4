const std = @import("std");

const Board = struct {
    board: std.PackedIntArray(i2, 42),

    pub fn init() Board {
        return Board{ .board = std.PackedIntArray(i2, 42).initAllTo(0) };
    }

    pub fn move(self: *Board, col: u3, player: i2) !void {
        var row: usize = 0;
        const usz_col: usize = @intCast(col);
        while (self.board.get(6 * usz_col + row) != 0) : (row += 1) {
            if (row >= 5) return error.Column_Full;
        }
        self.board.set(6 * usz_col + row, player);
    }

    pub fn reflect(self: *Board) Board {
        var new_board = Board.init();
        for (0..3) |col| {
            for (0..6) |row| {
                new_board.board.set(6 * col + row, self.board.get(6 * (6 - col) + row));
                new_board.board.set(6 * (6 - col) + row, self.board.get(6 * col + row));
            }
        }

        return new_board;
    }

    pub fn is_win(self: *Board) i2 {

        //check columns
        for (0..7) |col| {
            var prev: i2 = 0;
            var cnt: u8 = 0;
            for (0..6) |row| {
                const crnt = self.board.get(6 * col + row);
                if (crnt == 0) {
                    prev = 0;
                    cnt = 0;
                    break;
                }

                if (crnt != prev) {
                    prev = crnt;
                    cnt = 1;
                    continue;
                } else {
                    cnt += 1;
                }

                if (cnt >= 4) {
                    return crnt;
                }
            }
        }

        //check rows
        for (0..6) |row| {
            var prev: i2 = 0;
            var cnt: u8 = 0;
            for (0..7) |col| {
                const crnt = self.board.get(6 * col + row);
                if (crnt == 0) {
                    prev = 0;
                    cnt = 0;
                    continue;
                }

                if (crnt != prev) {
                    prev = crnt;
                    cnt = 1;
                    continue;
                } else {
                    cnt += 1;
                }

                if (cnt >= 4) {
                    return crnt;
                }
            }
        }

        //check diagonal lh1
        var i: usize = 0;
        while (i < 3) : (i += 1) {
            var j: usize = 0;
            var prev: i2 = 0;
            var cnt: u8 = 0;
            while (j < 7 * (6 - i)) : (j += 7) {
                const crnt = self.board.get(i + j);
                if (crnt == 0) {
                    prev = 0;
                    cnt = 0;
                    continue;
                }

                if (crnt != prev) {
                    prev = crnt;
                    cnt = 1;
                    continue;
                } else {
                    cnt += 1;
                }

                if (cnt >= 4) {
                    return crnt;
                }
            }
        }

        //check diagonal lh2
        i = 6;
        while (i <= 18) : (i += 6) {
            var j: usize = 0;
            var prev: i2 = 0;
            var cnt: u8 = 0;
            while (j < 7 * (7 - i / 6)) : (j += 7) {
                const crnt = self.board.get(i + j);
                if (crnt == 0) {
                    prev = 0;
                    cnt = 0;
                    continue;
                }

                if (crnt != prev) {
                    prev = crnt;
                    cnt = 1;
                    continue;
                } else {
                    cnt += 1;
                }

                if (cnt >= 4) {
                    return crnt;
                }
            }
        }

        //check diagonal hl1
        i = 3;
        while (i < 6) : (i += 1) {
            var j: usize = 0;
            var prev: i2 = 0;
            var cnt: u8 = 0;
            while (j < 5 * (i + 1)) : (j += 5) {
                const crnt = self.board.get(i + j);
                if (crnt == 0) {
                    prev = 0;
                    cnt = 0;
                    continue;
                }

                if (crnt != prev) {
                    prev = crnt;
                    cnt = 1;
                    continue;
                } else {
                    cnt += 1;
                }

                if (cnt >= 4) {
                    return crnt;
                }
            }
        }

        //check diagonal hl2
        i = 11;
        while (i <= 23) : (i += 1) {
            var j: usize = 0;
            var prev: i2 = 0;
            var cnt: u8 = 0;
            while (j < 5 * (6 - (i - 11) / 6)) : (j += 5) {
                const crnt = self.board.get(i + j);
                if (crnt == 0) {
                    prev = 0;
                    cnt = 0;
                    continue;
                }

                if (crnt != prev) {
                    prev = crnt;
                    cnt = 1;
                    continue;
                } else {
                    cnt += 1;
                }

                if (cnt >= 4) {
                    return crnt;
                }
            }
        }

        return 0;
    }

    pub fn check_cols(self: *Board) [7]bool {
        var checks: [7]bool = undefined;
        for (0..7) |i| {
            if (self.board.get(5 + 6 * i) == 0) {
                checks[i] = true;
            } else {
                checks[i] = false;
            }
        }
        return checks;
    }

    pub fn print_board(self: Board) void {
        std.debug.print("\n", .{});
        var row: usize = 6;
        while (row > 0) {
            row -= 1;
            for (0..7) |col| {
                const val = self.board.get(6 * col + row);
                if (val == -1) {
                    std.debug.print(" X", .{});
                } else if (val == 1) {
                    std.debug.print(" O", .{});
                } else {
                    std.debug.print(" #", .{});
                }
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }
};

pub fn Queue(comptime T: type) type {
    return struct {
        const This = @This();
        const QNode = struct {
            data: T,
            next: ?*QNode,
        };
        a: std.mem.Allocator,
        start: ?*QNode,
        end: ?*QNode,
        len: usize,

        pub fn init(a: std.mem.Allocator) This {
            return This{ .a = a, .start = null, .end = null, .len = 0 };
        }
        pub fn in(this: *This, value: T) !void {
            const node = try this.a.create(QNode);
            node.* = .{ .data = value, .next = null };
            if (this.end) |end| end.next = node //
            else this.start = node;
            this.end = node;
            this.len += 1;
        }
        pub fn out(this: *This) ?T {
            const start = this.start orelse return null;
            defer this.a.destroy(start);
            if (start.next) |next|
                this.start = next
            else {
                this.start = null;
                this.end = null;
            }
            this.len -= 1;
            return start.data;
        }
        pub fn deinit(this: *This) void {
            var crnt: ?T = this.out();
            while (crnt != null) {
                crnt = this.out();
            }
        }
    };
}

const Tree = struct {
    const TNode = struct {
        data: Board,
        children: [7]?*TNode,
        parents: std.ArrayList(*TNode),

        pub fn init(a: std.mem.Allocator, board: Board) !*TNode {
            const node: *TNode = try a.create(TNode);
            node.* = .{ 
            .data = board, 
            .children = [7]?*TNode{ null, null, null, null, null, null, null }, 
            .parents = std.ArrayList(*TNode).init(a)
            };
            return node;
        }

        pub fn deinit(self: *TNode, a: std.mem.Allocator) void {
            // Deinitialize children
            for (self.children) |maybe_child| {
                if (maybe_child) |child| {
                    for (0..child.parents.items.len) |i|{
                        if (child.parents.items[i] == self){
                            _ = child.parents.swapRemove(i);
                            break;
                        }
                    }
                    if (child.parents.items.len == 0) {
                        child.deinit(a);
                    }
                }
            }
            
            self.parents.deinit();
            a.destroy(self);
        }
    };
    
    root: *TNode,
    a: std.mem.Allocator,
    lvl: usize,
    player: i2,

    pub fn init(a: std.mem.Allocator) !Tree{
        return Tree{
            .root = try TNode.init(a, Board.init()),
            .a = a,
            .lvl = 0,
            .player = 1,
        };
    }

    fn add_terminals_to_queue(node: ?*TNode, q: *Queue(*TNode)) !void{
        if (node == null) return;

        var state = true;
        for (0..7) |i|{
            if (node.?.children[i] != null){
                state = false;
                break;
            }
        }
        if (state){
            try q.in(node.?);
        }

        for (node.?.children) |child|{
            try add_terminals_to_queue(child, q);
        }
    }

    pub fn propogate(self: *Tree, timer: i64) !void{
        var q:Queue(*TNode) = Queue(*TNode).init(self.a);
        errdefer q.deinit();
        try add_terminals_to_queue(self.root, &q);
        var h = std.AutoHashMap(Board, *TNode).init(self.a);
        errdefer h.deinit();

        const start_time = std.time.milliTimestamp();
        
        var qlen:usize = q.len;

        std.debug.print("level || Node Count\n", .{});
        std.debug.print("-------------------\n", .{});
        while (true){
            if (qlen == 0){
                self.lvl += 1;
                self.player *= -1;
                qlen = q.len;
                h.clearRetainingCapacity();
                std.debug.print("{}     || {}\n", .{self.lvl, qlen});
                if (std.time.milliTimestamp() - start_time > timer) break;
            }

            var crnt:*TNode = undefined;
            if (q.out()) |next| crnt = next else return error.QueueIsEmpty;
            qlen -= 1;

            if (self.lvl < 6){
                var col:u3 = 0;
                while (col < 7) : (col += 1){
                    var new_board = crnt.data;
                    try new_board.move(col, self.player);
                    if (h.get(new_board)) |node|{
                        try node.parents.append(crnt);
                        const usz_col:usize = @intCast(col);
                        crnt.children[usz_col] = node;
                    }else if (h.get(new_board.reflect())) |node|{
                        try node.parents.append(crnt);
                        const usz_col:usize = @intCast(col);
                        crnt.children[usz_col] = node;
                    }else{
                        const child = try TNode.init(self.a, new_board);
                        try child.parents.append(crnt);
                        const usz_col:usize = @intCast(col);
                        crnt.children[usz_col] = child;
                        try q.in(child);
                        try h.put(new_board, child);
                    }
                }
            }else{
                const available_cols = crnt.data.check_cols();
                for (0..7) |i|{
                    if (available_cols[i]){
                        var new_board = crnt.data;
                        const col:u3 = @intCast(i);
                        try new_board.move(col, self.player);
                        if (h.get(new_board)) |node|{
                            try node.parents.append(crnt);
                            crnt.children[i] = node;
                        }else if (h.get(new_board.reflect())) |node|{
                            try node.parents.append(crnt);
                            crnt.children[i] = node;
                        }else{
                            const child = try TNode.init(self.a, new_board);
                            try child.parents.append(crnt);
                            crnt.children[i] = child;
                            try h.put(new_board, child);
                            if (new_board.is_win() == 0){
                                try q.in(child);
                            }
                        }
                    }
                }
            }
        }
    }

    pub fn deinit(self: *Tree) void{
        self.root.deinit(self.a);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const a = gpa.allocator();
    errdefer std.debug.assert(gpa.deinit() == .ok);

    var tree = try Tree.init(a);
    errdefer tree.deinit();
    try tree.propogate(1000);
}
