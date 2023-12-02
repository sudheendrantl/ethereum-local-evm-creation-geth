import json

try:

    # modify existing json file with contents from node1.txt, node2.txt
    with open("genesis.json", 'r') as fhandle:
        genesis = json.loads(fhandle.read())

    f = open("node1.txt")
    node1 = f.read()
    f.close()
    node1=node1[60:100]

    f = open("node2.txt")
    node2 = f.read()
    f.close()
    node2=node2[60:100]

    str1=genesis['extradata'][:66]
    str2=genesis['extradata'][66:106]
    str3=genesis['extradata'][106:146]
    str4=genesis['extradata'][146:len(genesis['extradata'])+1]
    str5=str1+node1+node2+str4
    genesis['extradata']=str5

    keys=list(genesis['alloc'].keys())
    val = genesis['alloc'][keys[0]]
    del genesis['alloc'][keys[0]]
    genesis['alloc'][node1]=val
    val = genesis['alloc'][keys[1]]
    del genesis['alloc'][keys[1]]
    genesis['alloc'][node2]=val

    with open("genesis.json", 'w') as fhandle:
        fhandle.write(json.dumps(genesis, indent=2))

    # extracting chainid details

    with open("chainid.txt", 'w') as fhandle:
        fhandle.write(str(genesis['config']['chainId']))

    # extracting node1 details

    with open("node1.txt", 'r') as fhandle:
        node1 = fhandle.read()

    ss = "Public address of the key:   "
    idx = node1.find(ss)

    with open("node11.txt", 'w') as fhandle:
        fhandle.write(node1[idx+len(ss):42+idx+len(ss)])

    # extracting node2 details

    with open("node2.txt", 'r') as fhandle:
        node2 = fhandle.read()

    idx = node2.find(ss)

    with open("node22.txt", 'w') as fhandle:
        fhandle.write(node2[idx+len(ss):42+idx+len(ss)])

    # extracting node1 details

    with open("node3.txt", 'r') as fhandle:
        node3 = fhandle.read()

    idx = node3.find(ss)

    with open("node33.txt", 'w') as fhandle:
        fhandle.write(node3[idx+len(ss):42+idx+len(ss)])

except Exception as e:
    print("Exception occurred...", e)
