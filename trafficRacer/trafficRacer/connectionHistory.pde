class connectionHistory {
  int fromNode;
  int toNode;
  int innovationNumber;

  ArrayList<Integer> innovationNumbers = new ArrayList<Integer>();
  connectionHistory(int from, int to, int inno, ArrayList<Integer> innovationNos) {
    fromNode = from;
    toNode = to;
    innovationNumber = inno;
    innovationNumbers = (ArrayList)innovationNos.clone();
  }
  boolean matches(Genome genome, Node from, Node to) {
    if (genome.genes.size() == innovationNumbers.size()) { 
      if (from.number == fromNode && to.number == toNode) {
        for (int i = 0; i< genome.genes.size(); i++) {
          if (!innovationNumbers.contains(genome.genes.get(i).innovationNo)) {
            return false;
          }
        }

        return true;
      }
    }
    return false;
  }
}
