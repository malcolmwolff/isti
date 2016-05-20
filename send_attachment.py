import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
from email.MIMEBase import MIMEBase
from email import encoders
from email.utils import COMMASPACE, formatdate

# This function defines an email sending mechanism
def send_mail(fromaddr,frompass,toaddr,subj,bod,fname,fpath):

	msg = MIMEMultipart()

	msg['From'] = fromaddr
	msg['To'] = toaddr
	msg['Subject'] = subj

	body = bod

	msg.attach(MIMEText(body,'plain'))

	filename = fname
	attachment = open(fpath,"rb")

	part = MIMEBase('application','octet-stream')
	part.set_payload((attachment).read())
	encoders.encode_base64(part)
	part.add_header('Content-Disposition',"attachment; filename = %s" % filename)

	msg.attach(part)

	server = smtplib.SMTP('smtp.gmail.com',587)
	server.starttls()
	server.login(fromaddr,frompass)
	text = msg.as_string()
	server.sendmail(fromaddr,toaddr,text)
	server.quit()


def main():
    fromaddr = "m.lee.wolff@gmail.com"
    frompass = "**********"
    toaddr = "m.lee.wolff@gmail.com, mlw32@uw.edu"
    subj = "testing"
    bod = "testing!!!!"
    fname = "TEST.docx"
    fpath = "/Users/Mwolff/Desktop/TEST.docx"

    send_mail(fromaddr,frompass,toaddr,subj,bod,fname,fpath)

if __name__ == "__main__":
    main()
