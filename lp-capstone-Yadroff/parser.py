f = open("family.ged", "r", encoding='utf-8')
file = f.readlines()
f.close()
relative = {}
for s in file:
    if s.find('INDI') != -1:
        ID = s.split(' ')[1].rstrip()
    elif (s.find('GIVN')) != -1:
        name_and_surname = s.split(' ')[2].rstrip()
    elif s.find('SURN') != -1:
        name_and_surname = name_and_surname + ' ' + s.split(' ')[2].rstrip()
    elif s.find('SEX') != -1:
        if s.split(' ')[2].rstrip() == 'F':
            relative[ID] = [name_and_surname, '-1', '-1', 'female']
        else:
            relative[ID] = [name_and_surname, '-1', '-1', 'male']
    if s.find('HUSB') != -1:
        father = relative[s.split(' ')[2].rstrip()][0]
    elif s.find('WIFE') != -1:
        mother = relative[s.split(' ')[2].rstrip()][0]
    elif s.find('CHIL') != -1:
        relative[s.split(' ')[2].rstrip()][1] = father
        relative[s.split(' ')[2].rstrip()][2] = mother
outfile = open("res.pl", "w")
for i in relative:
    if relative[i][1] != '-1':
        outfile.write("child('" + relative[i][0] + "','" + relative[i][1] + "').\n")
    if relative[i][2] != '-1':
        outfile.write("child('" + relative[i][0] + "','" + relative[i][2] + "').\n")
for i in relative:
    if relative[i][3] == 'male':
        outfile.write(relative[i][3] + "('" + relative[i][0] + "').\n")
for i in relative:
    if relative[i][3] == 'female':
        outfile.write(relative[i][3] + "('" + relative[i][0] + "').\n")
outfile.close()
