#!/usr/bin/env python3
"""Generate Advanced iOS Quiz PDF -- compact exam style, multiple questions per page."""

from fpdf import FPDF
from fpdf.enums import XPos, YPos
import os

SF       = "/Library/Fonts/SF-Pro.ttf"
SF_ITALIC = "/Library/Fonts/SF-Pro-Italic.ttf"

DARK  = (20,  20,  35)
GREY  = (100, 100, 120)
BLACK = (0,   0,   0)
WHITE = (255, 255, 255)
BLUE  = (0,   90,  200)
CODE_BG   = (240, 242, 244)
CODE_TEXT = (30,  30,  50)

QUESTIONS = [
    {
        "num": 1,
        "week": "Week 1 - MVVM",
        "q": "In MVVM (iOS 13+), which property wrapper should a view use when it CREATES and OWNS the ViewModel for its entire lifetime?",
        "options": [
            "@ObservedObject var vm: FarmViewModel",
            "@StateObject private var vm: FarmViewModel",
            "@EnvironmentObject var vm: FarmViewModel",
            "@State private var vm = FarmViewModel()",
        ],
        "correct": "B",
    },
    {
        "num": 2,
        "week": "Week 2 - CoreData",
        "q": "Why should you use NSPredicate on a @FetchRequest instead of Swift .filter{} to show only expense transactions?",
        "options": [
            "NSPredicate is faster to write and has cleaner syntax",
            "NSPredicate filters inside SQLite, loading only matching rows into memory",
            "Swift .filter{} cannot compare String properties",
            ".filter{} requires a different managedObjectContext",
        ],
        "correct": "B",
    },
    {
        "num": 3,
        "week": "Week 2 - CoreData",
        "q": "What does the @NSManaged attribute tell the Swift compiler when applied to a CoreData property?",
        "options": [
            "The property is immutable after creation",
            "The property's storage is handled by CoreData's Objective-C runtime, not Swift",
            "The property will be automatically saved every second",
            "The property is excluded from the .xcdatamodeld schema",
        ],
        "correct": "B",
    },
    {
        "num": 4,
        "week": "Week 3 - Navigation",
        "q": "In iOS 13+, what is the correct way to navigate programmatically to a detail view from code (not just from a tap)?",
        "options": [
            "NavigationStack { }.navigationDestination(for: UUID.self)",
            "NavigationLink(tag: id, selection: $selectedID) { DetailView() } label: { EmptyView() }",
            'NavigationLink(destination: DetailView()) { Text("Go") }',
            "@Environment(\\.dismiss) var dismiss",
        ],
        "correct": "B",
    },
    {
        "num": 5,
        "week": "Week 5 - Notifications",
        "q": "Which class and method do you call first before scheduling a local notification in iOS 13+?",
        "options": [
            "NotificationCenter.default.post(name:object:)",
            "UNUserNotificationCenter.current().requestAuthorization(options:completionHandler:)",
            "UNNotificationRequest.schedule(after:repeats:)",
            'UserDefaults.standard.set(true, forKey: "notificationsAllowed")',
        ],
        "correct": "B",
    },
    {
        "num": 6,
        "week": "Week 8 - Dashboard",
        "q": "What does @ViewBuilder enable in a generic container like DashboardSection<Content: View>?",
        "options": [
            "It allows the struct to inherit from UIView",
            "It lets the caller pass a closure returning multiple SwiftUI views without wrapping in a Group",
            "It enables live-preview rendering in Xcode Canvas",
            "It replaces the need for @EnvironmentObject in child views",
        ],
        "correct": "B",
    },
    {
        "num": 7,
        "week": "Week 9 - Animations",
        "q": "What is the primary advantage of extracting repeated .padding().background().cornerRadius() into a custom ViewModifier?",
        "options": [
            "ViewModifiers run on a background thread and improve performance",
            "Styling is centralised -- changing the modifier updates every view that applies it",
            "ViewModifiers bypass the SwiftUI layout system for faster rendering",
            "ViewModifiers allow you to call UIKit methods directly",
        ],
        "correct": "B",
    },
    {
        "num": 8,
        "week": "Week 10 - Export",
        "q": "In iOS 13+, which API is used to generate a formatted PDF report with text and tables?",
        "options": [
            "ImageRenderer -- capture a SwiftUI view as a PDF",
            "UIGraphicsPDFRenderer -- draw text, tables, and graphics into a PDF context",
            "PDFDocument from PDFKit with appendPage()",
            "ShareLink with a URL to a pre-built template",
        ],
        "correct": "B",
    },
    {
        "num": 9,
        "week": "Week 2 - CoreData  [Complete the Code]",
        "q": "(Complete the Code) What belongs on the blank line to persist the record across app restarts?",
        "code": [
            "func addTransaction(",
            "    amount: Double, note: String,",
            "    type: String, category: String",
            ") {",
            "    let t = Transaction(context: context)",
            "    t.amount   = amount",
            "    t.note     = note",
            "    t.type     = type",
            "    t.category = category",
            "    t.id       = UUID()",
            "    _______________   // <- what goes here?",
            "}",
        ],
        "options": [
            "context.insert(t)",
            "context.refresh(t, mergeChanges: true)",
            "saveContext()",
            "context.fetch(Transaction.fetchRequest())",
        ],
        "correct": "C",
    },
    {
        "num": 10,
        "week": "Week 7 - Photos  [Complete the Code]",
        "q": "(Complete the Code) What should picker.delegate be set to?",
        "code": [
            "struct ImagePicker: UIViewControllerRepresentable {",
            "    @Binding var image: UIImage?",
            "    func makeCoordinator() -> Coordinator { Coordinator(self) }",
            "    func makeUIViewController(context: Context)",
            "        -> UIImagePickerController {",
            "        let picker = UIImagePickerController()",
            "        picker.delegate = _______________",
            "        return picker",
            "    }",
            "}",
        ],
        "options": [
            "self",
            "context.coordinator",
            "UIImagePickerController()",
            "Coordinator(self)",
        ],
        "correct": "B",
    },
    {
        "num": 11,
        "week": "Week 12 - TestFlight",
        "q": "Before running Product -> Archive in Xcode to upload to TestFlight, what must you select in the device/scheme destination picker?",
        "options": [
            "iPhone 15 Pro (Simulator)",
            "My Mac (Designed for iPad)",
            "Any iOS Device (arm64)",
            "Generic iOS Device (x86_64)",
        ],
        "correct": "C",
    },
    {
        "num": 12,
        "week": "Week 12 - Final Polish",
        "q": "Why must LaunchScreen.storyboard contain only static images -- no Swift code, no animations, no @IBOutlet connections?",
        "options": [
            "Xcode strips all code from storyboard files during archive",
            "The OS renders the launch screen before the app process starts -- no Swift runtime is available yet",
            "Animations in storyboards require iOS 16+ and break backward compatibility",
            "App Store review tools flag storyboards that reference Swift classes",
        ],
        "correct": "B",
    },
    {
        "num": 13,
        "week": "Git - Three Areas",
        "q": "What is the correct order of Git's three storage areas when you save a code change permanently?",
        "options": [
            "Repository -> Staging Area -> Working Directory",
            "Working Directory -> Repository -> Staging Area",
            "Staging Area -> Working Directory -> Repository",
            "Working Directory -> Staging Area -> Repository",
        ],
        "correct": "D",
    },
    {
        "num": 14,
        "week": "Git - Branching",
        "q": "Which single Git command creates a new branch 'feature/login' AND immediately switches to it?",
        "options": [
            "git branch feature/login",
            "git merge feature/login",
            "git switch -c feature/login",
            "git push -u origin feature/login",
        ],
        "correct": "C",
    },
]

LETTERS = ["A", "B", "C", "D"]


class ExamPDF(FPDF):
    def header(self):
        pass

    def footer(self):
        self.set_y(-12)
        self.set_font("SF", size=8)
        self.set_text_color(*GREY)
        self.cell(0, 6, f"Advanced iOS Quiz -- Week 1-12 + Git   |   Page {self.page_no()}", align="C")
        self.set_text_color(*BLACK)

    def draw_line(self):
        self.set_draw_color(180, 180, 200)
        self.line(self.l_margin, self.get_y(), self.l_margin + self.epw, self.get_y())
        self.ln(2)

    def question_block(self, q):
        """Render one question. Returns True if a page break happened."""
        lh_q  = 5.5   # question text line height
        lh_op = 5.2   # option line height
        lh_co = 4.6   # code line height
        pad   = 3      # padding inside code block

        # ── estimate height needed ────────────────────────────────────────
        self.set_font("SF", style="B", size=10)
        q_lines = max(1, -(-int(self.get_string_width(f"{q['num']}. {q['q']}")) // int(self.epw - 6)) )

        code_lines = q.get("code", [])
        code_h = len(code_lines) * lh_co + pad * 2 + 2 if code_lines else 0

        self.set_font("SF", size=9.5)
        opt_h = 0
        for opt in q["options"]:
            n = max(1, -(-int(self.get_string_width(f"   {opt}")) // int(self.epw - 10)) )
            opt_h += n * lh_op + 1.5

        total_h = q_lines * lh_q + code_h + opt_h + 8

        if self.get_y() + total_h > self.page_break_trigger:
            self.add_page()
            self.draw_line()

        # ── question number + text ────────────────────────────────────────
        self.set_font("SF", style="B", size=10)
        self.set_text_color(*BLACK)
        prefix = f"{q['num']}. "
        pw = self.get_string_width(prefix)
        x0 = self.l_margin
        self.set_x(x0)
        self.cell(pw, lh_q, prefix)
        self.set_font("SF", style="B", size=10)
        self.multi_cell(self.epw - pw, lh_q, q["q"])
        self.ln(1.5)

        # ── code block ───────────────────────────────────────────────────
        if code_lines:
            cx = self.l_margin + 4
            cw = self.epw - 4
            cy = self.get_y()
            bh = len(code_lines) * lh_co + pad * 2
            self.set_fill_color(*CODE_BG)
            self.rect(cx, cy, cw, bh, style="F")
            self.set_font("Courier", size=8)
            self.set_text_color(*CODE_TEXT)
            ty = cy + pad
            for line in code_lines:
                self.set_xy(cx + pad, ty)
                if "_______________" in line:
                    before, _, after = line.partition("_______________")
                    self.cell(self.get_string_width(before), lh_co, before)
                    # yellow highlight for blank
                    bx2 = self.get_x()
                    blank = "_______________"
                    bw2 = self.get_string_width(blank) + 2
                    self.set_fill_color(255, 230, 0)
                    self.rect(bx2, ty, bw2, lh_co, style="F")
                    self.set_font("Courier", style="B", size=8)
                    self.set_text_color(*CODE_TEXT)
                    self.set_xy(bx2, ty)
                    self.cell(bw2, lh_co, blank)
                    self.set_font("Courier", size=7)
                    self.set_text_color(140, 140, 160)
                    self.cell(cw, lh_co, after)
                    self.set_text_color(*CODE_TEXT)
                    self.set_font("Courier", size=8)
                else:
                    self.cell(cw - pad, lh_co, line)
                ty += lh_co
            self.set_y(cy + bh + 2)
            self.set_text_color(*BLACK)

        # ── options ──────────────────────────────────────────────────────
        self.set_font("SF", size=9.5)
        self.set_text_color(*BLACK)
        for i, opt in enumerate(q["options"]):
            letter = LETTERS[i]
            self.set_x(self.l_margin + 6)
            prefix_opt = f"{letter}.  "
            pw2 = self.get_string_width(prefix_opt)
            self.set_font("SF", style="B", size=9.5)
            self.cell(pw2, lh_op, prefix_opt)
            self.set_font("SF", size=9.5)
            self.multi_cell(self.epw - pw2 - 6, lh_op, opt)
            self.ln(0.5)

        self.ln(3)


def build_pdf():
    pdf = ExamPDF(orientation="P", unit="mm", format="A4")
    pdf.set_auto_page_break(auto=True, margin=16)
    pdf.set_margins(18, 18, 18)
    pdf.add_font("SF", style="",   fname=SF)
    pdf.add_font("SF", style="B",  fname=SF)
    pdf.add_font("SF", style="I",  fname=SF_ITALIC)
    pdf.add_font("SF", style="BI", fname=SF_ITALIC)

    # ── Page 1: header ────────────────────────────────────────────────────────
    pdf.add_page()

    # School name
    pdf.set_font("SF", style="B", size=13)
    pdf.set_text_color(*BLACK)
    pdf.cell(0, 7, "Prek Leap National Institute of Agriculture", align="C",
             new_x=XPos.LMARGIN, new_y=YPos.NEXT)

    # Quiz title
    pdf.set_font("SF", style="B", size=16)
    pdf.set_text_color(*BLUE)
    pdf.cell(0, 9, "Advanced iOS Quiz", align="C",
             new_x=XPos.LMARGIN, new_y=YPos.NEXT)

    # Subtitle
    pdf.set_font("SF", size=9)
    pdf.set_text_color(*GREY)
    pdf.cell(0, 5, "14 Questions  |  Multiple Choice + Complete the Code  |  Week 1-12 + Git",
             align="C", new_x=XPos.LMARGIN, new_y=YPos.NEXT)

    pdf.ln(4)

    # Student name line
    pdf.set_font("SF", size=10)
    pdf.set_text_color(*BLACK)
    pdf.cell(40, 7, "Student Name :", new_x=XPos.RIGHT, new_y=YPos.TOP)
    pdf.set_draw_color(0, 0, 0)
    pdf.cell(100, 7, "", border="B", new_x=XPos.RIGHT, new_y=YPos.TOP)
    pdf.cell(10, 7, "", new_x=XPos.RIGHT, new_y=YPos.TOP)
    pdf.cell(15, 7, "Score :", new_x=XPos.RIGHT, new_y=YPos.TOP)
    pdf.cell(0, 7, "........  / 14", new_x=XPos.LMARGIN, new_y=YPos.NEXT)

    pdf.ln(3)

    # separator
    pdf.set_draw_color(*BLUE)
    pdf.set_line_width(0.5)
    pdf.line(pdf.l_margin, pdf.get_y(), pdf.l_margin + pdf.epw, pdf.get_y())
    pdf.set_line_width(0.2)
    pdf.set_draw_color(0, 0, 0)
    pdf.ln(4)

    # ── Questions ─────────────────────────────────────────────────────────────
    for q in QUESTIONS:
        pdf.question_block(q)
        pdf.draw_line()

    # ── save ──────────────────────────────────────────────────────────────────
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Advanced_iOS_Quiz.pdf")
    pdf.output(out)
    print(f"PDF saved -> {out}")


if __name__ == "__main__":
    build_pdf()
