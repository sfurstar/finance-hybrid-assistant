from pathlib import Path
from reportlab.lib import colors
from reportlab.lib.enums import TA_RIGHT
from reportlab.lib.pagesizes import LETTER
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle

OUT_DIR = Path("poc_invoices")
OUT_DIR.mkdir(parents=True, exist_ok=True)

# invoice_id, customer_id, customer_name_doc, invoice_date, due_date_doc,
# amount_doc, currency, payment_terms_doc, po_number_doc, bill_to_address,
# service_period, description
INVOICES = [
    ("INV-1001","CUST001","Acme Manufacturing","2026-01-05","2026-02-04",18500.00,"USD","NET 30",None,"1250 Industrial Drive, Chicago, IL 60606","2026-01","January equipment maintenance services"),
    ("INV-1002","CUST001","Acme Manufacturing","2026-02-08","2026-03-15",22400.00,"USD","NET 30","PO-ACM-1002","1250 Industrial Drive, Chicago, IL 60606","2026-02","February replacement parts and inspection"),
    ("INV-1003","CUST001","Acme Manufacturing","2026-03-02","2026-04-01",19850.00,"USD","NET 30",None,"1250 Industrial Drive, Chicago, IL 60606","2026-03","March scheduled maintenance services"),

    ("INV-1004","CUST002","Northwind Retail Group","2026-01-11","2026-02-25",14200.00,"USD","NET 45",None,"800 Market Street, Boston, MA 02110","2026-01","Store systems support services"),
    ("INV-1005","CUST002","Northwind Retail Group","2026-02-14","2026-03-31",16750.00,"USD","NET 45",None,"800 Market Street, Boston, MA 02110","2026-02","POS integration support"),
    ("INV-1006","CUST002","Northwind Retail Group","2026-03-03","2026-04-17",15990.00,"USD","NET 45",None,"800 Market Street, Boston, MA 02110","2026-03","Retail reporting services"),

    ("INV-1007","CUST003","BluePeak Logistics","2026-01-07","2026-02-06",12600.00,"USD","NET 30",None,"4100 Logistics Parkway, Dallas, TX 75201","2026-01","Logistics optimization consulting"),
    ("INV-1008","CUST003","BluePeak Logistics","2026-02-09","2026-03-11",13150.00,"USD","NET 30",None,"4100 Logistics Parkway, Dallas, TX 75201","2026-02","Distribution routing analytics"),
    ("INV-1009","CUST003","BluePeak Logistics","2026-03-06","2026-04-05",14900.00,"USD","NET 30",None,"4100 Logistics Parkway, Dallas, TX 75201","2026-03","Freight operations reporting"),

    ("INV-1010","CUST004","Summit Health Systems","2026-01-09","2026-03-10",30750.00,"USD","NET 60","PO-SHS-1010","77 Health Plaza, San Diego, CA 92101","2026-01","Clinical data platform subscription"),
    ("INV-1011","CUST004","Summit Health Systems","2026-02-12","2026-04-13",31800.00,"USD","NET 60",None,"77 Health Plaza, San Diego, CA 92101","2026-02","Patient analytics services"),
    ("INV-1012","CUST004","Summit Health Systems","2026-03-04","2026-05-03",28900.00,"USD","NET 60",None,"77 Health Plaza, San Diego, CA 92101","2026-03","Healthcare reporting services"),

    ("INV-1013","CUST005","Evergreen Industrial Supply","2026-01-06","2026-02-05",11200.00,"USD","NET 30",None,"220 Foundry Way, Milwaukee, WI 53202","2026-01","Industrial supply planning support"),
    ("INV-1014","CUST005","Evergreen Industrial Supply","2026-02-10","2026-03-12",11850.00,"USD","NET 30",None,"220 Foundry Way, Milwaukee, WI 53202","2026-02","Procurement optimization services"),
    ("INV-1015","CUST005","Evergreen Industrial Supply","2026-03-07","2026-04-06",12100.00,"USD","NET 30",None,"220 Foundry Way, Milwaukee, WI 53202","2026-03","Inventory reporting enhancement"),

    ("INV-1016","CUST006","Horizon Field Services","2026-01-13","2026-02-12",9800.00,"USD","NET 30",None,"901 Service Loop, Houston, TX 77002","2026-01","Field service dispatch support"),
    ("INV-1017","CUST006","Horizon Field Services","2026-02-17","2026-03-19",10450.00,"USD","NET 30",None,"901 Service Loop, Houston, TX 77002","2026-02","Technician utilization analytics"),
    ("INV-1018","CUST006","Horizon Field Services","2026-03-05","2026-04-04",10975.00,"USD","NET 30",None,"901 Service Loop, Houston, TX 77002","2026-03","Service performance reporting"),

    ("INV-1019","CUST007","Cedar Grove Hospitality","2026-01-08","2026-01-23",8700.00,"USD","NET 15",None,"55 Hospitality Lane, Orlando, FL 32801","2026-01","Hospitality booking insights"),
    ("INV-1020","CUST007","Cedar Grove Hospitality","2026-02-11","2026-02-26",9250.00,"USD","NET 15",None,"55 Hospitality Lane, Orlando, FL 32801","2026-02","Guest operations dashboard"),
    ("INV-1021","CUST007","Cedar Grove Hospitality","2026-03-08","2026-03-23",9100.00,"USD","NET 15",None,"55 Hospitality Lane, Orlando, FL 32801","2026-03","Revenue management support"),

    ("INV-1022","CUST008","Atlas Construction Partners","2026-01-10","2026-02-24",21400.00,"USD","NET 45",None,"300 Builder Avenue, Phoenix, AZ 85004","2026-01","Construction schedule analytics"),
    ("INV-1023","CUST008","Atlas Construction Partners","2026-02-13","2026-03-30",19800.00,"USD","NET 30","PO-ACP-1023","300 Builder Avenue, Phoenix, AZ 85004","2026-02","Project cost reporting"),
    ("INV-1024","CUST008","Atlas Construction Partners","2026-03-09","2026-04-23",23600.00,"USD","NET 45",None,"300 Builder Avenue, Phoenix, AZ 85004","2026-03","Labor forecasting services"),

    ("INV-1025","CUST009","Brightline Education Network","2026-01-14","2026-02-13",7600.00,"USD","NET 30",None,"12 Education Circle, Newark, NJ 07102","2026-01","Student performance reporting"),
    ("INV-1026","CUST009","Brightline Education Network","2026-02-18","2026-03-20",8200.00,"USD","NET 30",None,"12 Education Circle, Newark, NJ 07102","2026-02","Education KPI dashboard"),
    ("INV-1027","CUST009","Brightline Education Network","2026-03-10","2026-04-09",8450.00,"USD","NET 30",None,"12 Education Circle, Newark, NJ 07102","2026-03","Enrollment trend analysis"),

    ("INV-1028","CUST010","Red River Energy","2026-01-12","2026-03-13",27600.00,"USD","NET 60",None,"890 Energy Corridor, Tulsa, OK 74103","2026-01","Energy operations reporting"),
    ("INV-1029","CUST010","Red River Energy","2026-02-16","2026-04-17",28850.00,"USD","NET 60",None,"890 Energy Corridor, Tulsa, OK 74103","2026-02","Well production analytics"),
    ("INV-1030","CUST010","Red River Energy","2026-03-06","2026-05-05",29400.00,"USD","NET 60",None,"890 Energy Corridor, Tulsa, OK 74103","2026-03","Field output forecasting"),

    ("INV-1031","CUST011","Sterling Business Solutions","2026-01-15","2026-02-14",13400.00,"USD","NET 30",None,"1 Advisory Square, Indianapolis, IN 46204","2026-01","Business advisory services"),
    ("INV-1032","CUST011","Sterling Biz Solutions","2026-02-19","2026-03-21",14150.00,"USD","NET 30",None,"1 Advisory Square, Indianapolis, IN 46204","2026-02","Performance scorecard development"),
    ("INV-1033","CUST011","Sterling Business Solutions","2026-03-07","2026-04-06",13800.00,"USD","NET 30",None,"1 Advisory Square, Indianapolis, IN 46204","2026-03","Finance process optimization"),

    ("INV-1034","CUST012","Lakefront Food Distributors","2026-01-16","2026-02-06",11900.00,"USD","NET 21",None,"640 Harbor Distribution Blvd, Cleveland, OH 44114","2026-01","Distribution efficiency analytics"),
    ("INV-1035","CUST012","Lakefront Food Distributors","2026-02-15","2026-03-08",12350.00,"USD","NET 21","PO-LFD-22081","640 Harbor Distribution Blvd, Cleveland, OH 44114","2026-02","Warehouse throughput reporting"),
    ("INV-1036","CUST012","Lakefront Food Distributors","2026-03-09","2026-03-30",12825.00,"USD","NET 21",None,"640 Harbor Distribution Blvd, Cleveland, OH 44114","2026-03","Route planning dashboard support"),
]

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name="Body10", parent=styles["BodyText"], fontSize=10, leading=13))
styles.add(ParagraphStyle(name="Small9", parent=styles["BodyText"], fontSize=9, leading=11))
styles.add(ParagraphStyle(name="Right10", parent=styles["BodyText"], fontSize=10, leading=13, alignment=TA_RIGHT))

def money(v: float) -> str:
    return f"${v:,.2f}"

def build_invoice_pdf(row):
    (
        invoice_id, customer_id, customer_name_doc, invoice_date, due_date_doc,
        amount_doc, currency, payment_terms_doc, po_number_doc, bill_to_address,
        service_period, description
    ) = row

    path = OUT_DIR / f"{invoice_id}.pdf"
    doc = SimpleDocTemplate(
        str(path),
        pagesize=LETTER,
        leftMargin=0.65 * inch,
        rightMargin=0.65 * inch,
        topMargin=0.60 * inch,
        bottomMargin=0.65 * inch,
    )

    story = []

    header = Table(
        [[
            Paragraph(
                "<b>Northstar Business Analytics</b><br/>"
                "Accounts Receivable Services<br/>"
                "410 W Monroe St<br/>Chicago, IL 60606",
                styles["Body10"]
            ),
            Paragraph(
                f"<b>INVOICE</b><br/><br/>"
                f"<b>Invoice No:</b> {invoice_id}<br/>"
                f"<b>Invoice Date:</b> {invoice_date}<br/>"
                f"<b>Due Date:</b> {due_date_doc}",
                styles["Right10"]
            )
        ]],
        colWidths=[3.9 * inch, 2.5 * inch],
    )
    header.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
    ]))
    story.append(header)
    story.append(Spacer(1, 0.18 * inch))

    summary = Table(
        [
            [
                Paragraph("<b>Bill To</b>", styles["Body10"]),
                Paragraph("<b>Invoice Summary</b>", styles["Body10"])
            ],
            [
                Paragraph(f"{customer_name_doc}<br/>{bill_to_address}", styles["Body10"]),
                Paragraph(
                    f"<b>Customer ID:</b> {customer_id}<br/>"
                    f"<b>Terms:</b> {payment_terms_doc}<br/>"
                    f"<b>Currency:</b> {currency}"
                    + (f"<br/><b>PO Number:</b> {po_number_doc}" if po_number_doc else ""),
                    styles["Body10"]
                )
            ]
        ],
        colWidths=[3.9 * inch, 2.5 * inch],
    )
    summary.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#e8f0fb")),
        ("BOX", (0, 0), (-1, -1), 0.6, colors.HexColor("#a8badb")),
        ("INNERGRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#ccd8ec")),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 8),
        ("RIGHTPADDING", (0, 0), (-1, -1), 8),
        ("TOPPADDING", (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
    ]))
    story.append(summary)
    story.append(Spacer(1, 0.22 * inch))

    lines = Table(
        [
            [
                Paragraph("<b>Service Period</b>", styles["Small9"]),
                Paragraph("<b>Description</b>", styles["Small9"]),
                Paragraph("<b>Qty</b>", styles["Small9"]),
                Paragraph("<b>Rate</b>", styles["Small9"]),
                Paragraph("<b>Line Total</b>", styles["Small9"]),
            ],
            [
                Paragraph(service_period, styles["Body10"]),
                Paragraph(description, styles["Body10"]),
                Paragraph("1", styles["Body10"]),
                Paragraph(money(amount_doc), styles["Body10"]),
                Paragraph(money(amount_doc), styles["Body10"]),
            ],
        ],
        colWidths=[1.1 * inch, 3.0 * inch, 0.55 * inch, 1.0 * inch, 1.05 * inch],
    )
    lines.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#1f3c88")),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("BOX", (0, 0), (-1, -1), 0.6, colors.HexColor("#a0a8b8")),
        ("INNERGRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#cdd4de")),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("ALIGN", (2, 1), (-1, -1), "CENTER"),
        ("LEFTPADDING", (0, 0), (-1, -1), 8),
        ("RIGHTPADDING", (0, 0), (-1, -1), 8),
        ("TOPPADDING", (0, 0), (-1, -1), 8),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
    ]))
    story.append(lines)
    story.append(Spacer(1, 0.18 * inch))

    totals = Table(
        [
            ["Subtotal", money(amount_doc)],
            ["Tax", money(0.00)],
            ["Total Amount Due", money(amount_doc)],
        ],
        colWidths=[1.6 * inch, 1.4 * inch],
    )
    totals.setStyle(TableStyle([
        ("BOX", (0, 0), (-1, -1), 0.6, colors.HexColor("#a0a8b8")),
        ("INNERGRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#d8dee7")),
        ("BACKGROUND", (0, 2), (-1, 2), colors.HexColor("#edf5eb")),
        ("FONTNAME", (0, 2), (-1, 2), "Helvetica-Bold"),
        ("ALIGN", (0, 0), (-1, -1), "RIGHT"),
        ("LEFTPADDING", (0, 0), (-1, -1), 8),
        ("RIGHTPADDING", (0, 0), (-1, -1), 8),
        ("TOPPADDING", (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
    ]))

    totals_wrap = Table(
        [[
            Paragraph(
                "Please remit payment by the due date shown above. "
                "Include the invoice number with your payment advice.",
                styles["Body10"]
            ),
            totals
        ]],
        colWidths=[4.6 * inch, 2.2 * inch],
    )
    totals_wrap.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP")
    ]))
    story.append(totals_wrap)
    story.append(Spacer(1, 0.18 * inch))

    story.append(
        Paragraph(
            "Questions regarding this invoice may be directed to "
            "ar@northstarba.example. Thank you for your business.",
            styles["Small9"]
        )
    )

    doc.build(story)

for invoice in INVOICES:
    build_invoice_pdf(invoice)

print(f"Created {len(INVOICES)} PDFs in {OUT_DIR.resolve()}")