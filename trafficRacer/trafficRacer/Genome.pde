class Genome {
  ArrayList<connectionGene> genes = new  ArrayList<connectionGene>();
  ArrayList<Node> nodes = new ArrayList<Node>();//list of nodes
  int inputs;
  int outputs;
  int layers =2;
  int nextNode = 0;
  int biasNode;

  ArrayList<Node> network = new ArrayList<Node>();//a list of the nodes in the order that they need to be considered in the NN
  Genome(int in, int out) {
    //set input number and output number
    inputs = in;
    outputs = out;

    for (int i = 0; i<inputs; i++) {
      nodes.add(new Node(i));
      nextNode ++;
      nodes.get(i).layer =0;
    }

    for (int i = 0; i < outputs; i++) {
      nodes.add(new Node(i+inputs));
      nodes.get(i+inputs).layer = 1;
      nextNode++;
    }

    nodes.add(new Node(nextNode));//bias node
    biasNode = nextNode; 
    nextNode++;
    nodes.get(biasNode).layer = 0;
  }

  Node getNode(int nodeNumber) {
    for (int i = 0; i < nodes.size(); i++) {
      if (nodes.get(i).number == nodeNumber) {
        return nodes.get(i);
      }
    }
    return null;
  }

  void connectNodes() {

    for (int i = 0; i< nodes.size(); i++) {
      nodes.get(i).outputConnections.clear();
    }

    for (int i = 0; i < genes.size(); i++) {
      genes.get(i).fromNode.outputConnections.add(genes.get(i));
    }
  }
  float[] feedForward(float[] inputValues) {
    //set the outputs of the input nodes
    for (int i =0; i < inputs; i++) {
      nodes.get(i).outputValue = inputValues[i];
    }
    nodes.get(biasNode).outputValue = 1;

    for (int i = 0; i< network.size(); i++) {
      network.get(i).engage();
    }
    float[] outs = new float[outputs];
    for (int i = 0; i < outputs; i++) {
      outs[i] = nodes.get(inputs + i).outputValue;
    }

    for (int i = 0; i < nodes.size(); i++) {
      nodes.get(i).inputSum = 0;
    }

    return outs;
  }

  void generateNetwork() {
    connectNodes();
    network = new ArrayList<Node>();

    for (int l = 0; l< layers; l++) {//for each layer
      for (int i = 0; i< nodes.size(); i++) {//for each node
        if (nodes.get(i).layer == l) {//if that node is in that layer
          network.add(nodes.get(i));
        }
      }
    }
  }
  void addNode(ArrayList<connectionHistory> innovationHistory) {
    if (genes.size() ==0) {
      addConnection(innovationHistory); 
      return;
    }
    int randomConnection = floor(random(genes.size()));

    while (genes.get(randomConnection).fromNode == nodes.get(biasNode) && genes.size() !=1 ) {
      randomConnection = floor(random(genes.size()));
    }

    genes.get(randomConnection).enabled = false;

    int newNodeNo = nextNode;
    nodes.add(new Node(newNodeNo));
    nextNode ++;
    int connectionInnovationNumber = getInnovationNumber(innovationHistory, genes.get(randomConnection).fromNode, getNode(newNodeNo));
    genes.add(new connectionGene(genes.get(randomConnection).fromNode, getNode(newNodeNo), 1, connectionInnovationNumber));


    connectionInnovationNumber = getInnovationNumber(innovationHistory, getNode(newNodeNo), genes.get(randomConnection).toNode);
    genes.add(new connectionGene(getNode(newNodeNo), genes.get(randomConnection).toNode, genes.get(randomConnection).weight, connectionInnovationNumber));
    getNode(newNodeNo).layer = genes.get(randomConnection).fromNode.layer +1;


    connectionInnovationNumber = getInnovationNumber(innovationHistory, nodes.get(biasNode), getNode(newNodeNo));
    genes.add(new connectionGene(nodes.get(biasNode), getNode(newNodeNo), 0, connectionInnovationNumber));

    if (getNode(newNodeNo).layer == genes.get(randomConnection).toNode.layer) {
      for (int i = 0; i< nodes.size() -1; i++) {//dont include this newest node
        if (nodes.get(i).layer >= getNode(newNodeNo).layer) {
          nodes.get(i).layer ++;
        }
      }
      layers ++;
    }
    connectNodes();
  }

  void addConnection(ArrayList<connectionHistory> innovationHistory) {
    if (fullyConnected()) {
      println("connection failed");
      return;
    }


    int randomNode1 = floor(random(nodes.size())); 
    int randomNode2 = floor(random(nodes.size()));
    while (randomConnectionNodesAreShit(randomNode1, randomNode2)) {
      randomNode1 = floor(random(nodes.size())); 
      randomNode2 = floor(random(nodes.size()));
    }
    int temp;
    if (nodes.get(randomNode1).layer > nodes.get(randomNode2).layer) {
      temp =randomNode2  ;
      randomNode2 = randomNode1;
      randomNode1 = temp;
    }    

    int connectionInnovationNumber = getInnovationNumber(innovationHistory, nodes.get(randomNode1), nodes.get(randomNode2));

    genes.add(new connectionGene(nodes.get(randomNode1), nodes.get(randomNode2), random(-1, 1), connectionInnovationNumber));
    connectNodes();
  }
  boolean randomConnectionNodesAreShit(int r1, int r2) {
    if (nodes.get(r1).layer == nodes.get(r2).layer) return true;
    if (nodes.get(r1).isConnectedTo(nodes.get(r2))) return true;



    return false;
  }

  int getInnovationNumber(ArrayList<connectionHistory> innovationHistory, Node from, Node to) {
    boolean isNew = true;
    int connectionInnovationNumber = nextConnectionNo;
    for (int i = 0; i < innovationHistory.size(); i++) {//for each previous mutation
      if (innovationHistory.get(i).matches(this, from, to)) {//if match found
        isNew = false;//its not a new mutation
        connectionInnovationNumber = innovationHistory.get(i).innovationNumber; //set the innovation number as the innovation number of the match
        break;
      }
    }

    if (isNew) {
      ArrayList<Integer> innoNumbers = new ArrayList<Integer>();
      for (int i = 0; i< genes.size(); i++) {//set the innovation numbers
        innoNumbers.add(genes.get(i).innovationNo);
      }
 
      innovationHistory.add(new connectionHistory(from.number, to.number, connectionInnovationNumber, innoNumbers));
      nextConnectionNo++;
    }
    return connectionInnovationNumber;
  }
  boolean fullyConnected() {
    int maxConnections = 0;
    int[] nodesInLayers = new int[layers];
    for (int i =0; i< nodes.size(); i++) {
      nodesInLayers[nodes.get(i).layer] +=1;
    }

    for (int i = 0; i < layers-1; i++) {
      int nodesInFront = 0;
      for (int j = i+1; j < layers; j++) {
        nodesInFront += nodesInLayers[j];
      }

      maxConnections += nodesInLayers[i] * nodesInFront;
    }

    if (maxConnections == genes.size()) {
      return true;
    }
    return false;
  }


  void mutate(ArrayList<connectionHistory> innovationHistory) {
    if (genes.size() ==0) {
      addConnection(innovationHistory);
    }

    float rand1 = random(1);
    if (rand1<0.8) { 
      for (int i = 0; i< genes.size(); i++) {
        genes.get(i).mutateWeight();
      }
    }
    float rand2 = random(1);
    if (rand2<0.08) {
      addConnection(innovationHistory);
    }


    float rand3 = random(1);
    if (rand3<0.02) {
      addNode(innovationHistory);
    }
  }
  Genome crossover(Genome parent2) {
    Genome child = new Genome(inputs, outputs, true);
    child.genes.clear();
    child.nodes.clear();
    child.layers = layers;
    child.nextNode = nextNode;
    child.biasNode = biasNode;
    ArrayList<connectionGene> childGenes = new ArrayList<connectionGene>();
    ArrayList<Boolean> isEnabled = new ArrayList<Boolean>(); 
    for (int i = 0; i< genes.size(); i++) {
      boolean setEnabled = true;

      int parent2gene = matchingGene(parent2, genes.get(i).innovationNo);
      if (parent2gene != -1) {
        if (!genes.get(i).enabled || !parent2.genes.get(parent2gene).enabled) {

          if (random(1) < 0.75) {
            setEnabled = false;
          }
        }
        float rand = random(1);
        if (rand<0.5) {
          childGenes.add(genes.get(i));

        } else {
          childGenes.add(parent2.genes.get(parent2gene));
        }
      } else {
        childGenes.add(genes.get(i));
        setEnabled = genes.get(i).enabled;
      }
      isEnabled.add(setEnabled);
    }


    for (int i = 0; i < nodes.size(); i++) {
      child.nodes.add(nodes.get(i).clone());
    }


    for ( int i =0; i<childGenes.size(); i++) {
      child.genes.add(childGenes.get(i).clone(child.getNode(childGenes.get(i).fromNode.number), child.getNode(childGenes.get(i).toNode.number)));
      child.genes.get(i).enabled = isEnabled.get(i);
    }

    child.connectNodes();
    return child;
  }

  Genome(int in, int out, boolean crossover) {
    //set input number and output number
    inputs = in; 
    outputs = out;
  }
  int matchingGene(Genome parent2, int innovationNumber) {
    for (int i =0; i < parent2.genes.size(); i++) {
      if (parent2.genes.get(i).innovationNo == innovationNumber) {
        return i;
      }
    }
    return -1; //no matching gene found
  }
  void printGenome() {
    println("Print genome  layers:", layers);  
    println("bias node: "  + biasNode);
    println("nodes");
    for (int i = 0; i < nodes.size(); i++) {
      print(nodes.get(i).number + ",");
    }
    println("Genes");
    for (int i = 0; i < genes.size(); i++) {//for each connectionGene 
      println("gene " + genes.get(i).innovationNo, "From node " + genes.get(i).fromNode.number, "To node " + genes.get(i).toNode.number, 
        "is enabled " +genes.get(i).enabled, "from layer " + genes.get(i).fromNode.layer, "to layer " + genes.get(i).toNode.layer, "weight: " + genes.get(i).weight);
    }

    println();
  }

  Genome clone() {

    Genome clone = new Genome(inputs, outputs, true);

    for (int i = 0; i < nodes.size(); i++) {
      clone.nodes.add(nodes.get(i).clone());
    }

    for ( int i =0; i<genes.size(); i++) {
      clone.genes.add(genes.get(i).clone(clone.getNode(genes.get(i).fromNode.number), clone.getNode(genes.get(i).toNode.number)));
    }

    clone.layers = layers;
    clone.nextNode = nextNode;
    clone.biasNode = biasNode;
    clone.connectNodes();

    return clone;
  }
  void drawGenome(int startX, int startY, int w, int h) {
    ArrayList<ArrayList<Node>> allNodes = new ArrayList<ArrayList<Node>>();
    ArrayList<PVector> nodePoses = new ArrayList<PVector>();
    ArrayList<Integer> nodeNumbers= new ArrayList<Integer>();

    for (int i = 0; i< layers; i++) {
      ArrayList<Node> temp = new ArrayList<Node>();
      for (int j = 0; j< nodes.size(); j++) {//for each node 
        if (nodes.get(j).layer == i ) {//check if it is in this layer
          temp.add(nodes.get(j)); //add it to this layer
        }
      }
      allNodes.add(temp);//add this layer to all nodes
    }

    for (int i = 0; i < layers; i++) {
      fill(255, 0, 0);
      float x = startX + (float)((i)*w)/(float)(layers-1);
      for (int j = 0; j< allNodes.get(i).size(); j++) {//for the position in the layer
        float y = startY + ((float)(j + 1.0) * h)/(float)(allNodes.get(i).size() + 1.0);
        nodePoses.add(new PVector(x, y));
        nodeNumbers.add(allNodes.get(i).get(j).number);
        if(i == layers -1){
         println(i,j,x,y); 
          
          
        }
      }
    }

    //draw connections 
    stroke(0);
    strokeWeight(2);
    for (int i = 0; i< genes.size(); i++) {
      if (genes.get(i).enabled) {
        stroke(0);
      } else {
        stroke(100);
      }
      PVector from;
      PVector to;
      from = nodePoses.get(nodeNumbers.indexOf(genes.get(i).fromNode.number));
      to = nodePoses.get(nodeNumbers.indexOf(genes.get(i).toNode.number));
      if (genes.get(i).weight > 0) {
        stroke(255, 0, 0);
      } else {
        stroke(0, 0, 255);
      }
      strokeWeight(map(abs(genes.get(i).weight), 0, 1, 0, 5));
      line(from.x, from.y, to.x, to.y);
    }
    for (int i = 0; i < nodePoses.size(); i++) {
      fill(255);
      stroke(0);
      strokeWeight(1);
      ellipse(nodePoses.get(i).x, nodePoses.get(i).y, 20, 20);
      textSize(10);
      fill(0);
      textAlign(CENTER, CENTER);


      text(nodeNumbers.get(i), nodePoses.get(i).x, nodePoses.get(i).y);
    }
  }
}
