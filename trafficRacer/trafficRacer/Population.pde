class Population {
  ArrayList<AiCar> pop = new ArrayList<AiCar>();
  AiCar bestPlayer;
  int bestScore =0;
  int gen;
  ArrayList<connectionHistory> innovationHistory = new ArrayList<connectionHistory>();
  ArrayList<AiCar> genPlayers = new ArrayList<AiCar>();
  ArrayList<Species> species = new ArrayList<Species>();

  boolean massExtinctionEvent = false;
  boolean newStage = false;
  int populationLife = 0;
  int aliveCount = 0;



  Population(int size) {

    for (int i =0; i<size; i++) {
      pop.add(new AiCar());
      pop.get(i).brain.generateNetwork();
      pop.get(i).brain.mutate(innovationHistory);
    }
  }

  void updateAlive() {
    aliveCount = 0;
    populationLife ++;
    for (int i = 0; i< pop.size(); i++) {
      if(pop.get(i).collided()){
        pop.get(i).dead = true;
      }
      if (!pop.get(i).dead) {
        aliveCount++;
        if(pop.get(i).score > bestScore){
          bestScore = pop.get(i).score;
        }
        pop.get(i).look();
        pop.get(i).doStuff();
        pop.get(i).show();
      }
    }
  }

  boolean done() {
    for (int i = 0; i< pop.size(); i++) {
      if (!pop.get(i).dead) {
        return false;
      }
    }
    return true;
  }

  void setBestPlayer() {
    AiCar tempBest =  species.get(0).players.get(0);
    tempBest.gen = gen;


  

    if (tempBest.score > bestScore) {
      println("old best:", bestScore);
      println("new best:", tempBest.score);
      bestScore = tempBest.score;
    }
  }

  void naturalSelection() {
    speciate();
    calculateFitness();
    sortSpecies();
    if (massExtinctionEvent) { 
      massExtinction();
      massExtinctionEvent = false;
    }
    cullSpecies();
    setBestPlayer();
    killStaleSpecies();
    killBadSpecies();


    println("generation", gen, "Number of mutations", innovationHistory.size(), "species: " + species.size(), "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");


    float averageSum = getAvgFitnessSum();
    ArrayList<AiCar> children = new ArrayList<AiCar>();
    println("Species:");               
    for (int j = 0; j < species.size(); j++) {

      println("best unadjusted fitness:", species.get(j).bestFitness);
      for (int i = 0; i < species.get(j).players.size(); i++) {
        print("player " + i, "fitness: " +  species.get(j).players.get(i).fitness, "score " + species.get(j).players.get(i).score, ' ');
      }
      println();
      children.add(species.get(j).champ.clone());

      int NoOfChildren = floor(species.get(j).averageFitness/averageSum * pop.size()) -1;
      for (int i = 0; i< NoOfChildren; i++) {
        children.add(species.get(j).giveMeBaby(innovationHistory));
      }
    }

    while (children.size() < pop.size()) {
      children.add(species.get(0).giveMeBaby(innovationHistory));]
    }
    pop.clear();
    pop = (ArrayList)children.clone(); 
    gen+=1;
    for (int i = 0; i< pop.size(); i++) {
      pop.get(i).brain.generateNetwork();
    }
    
    populationLife = 0;
  }

  void speciate() {
    for (Species s : species) {
      s.players.clear();
    }
    for (int i = 0; i< pop.size(); i++) {
      boolean speciesFound = false;
      for (Species s : species) {
        if (s.sameSpecies(pop.get(i).brain)) {
          s.addToSpecies(pop.get(i));
          speciesFound = true;
          break;
        }
      }
      if (!speciesFound) {
        species.add(new Species(pop.get(i)));
      }
    }
  } 
  void calculateFitness() {
    for (int i =1; i<pop.size(); i++) {
      pop.get(i).calculateFitness();
    }
  }
  void sortSpecies() {
    for (Species s : species) {
      s.sortSpecies();
    }

    ArrayList<Species> temp = new ArrayList<Species>();
    for (int i = 0; i < species.size(); i ++) {
      float max = 0;
      int maxIndex = 0;
      for (int j = 0; j< species.size(); j++) {
        if (species.get(j).bestFitness > max) {
          max = species.get(j).bestFitness;
          maxIndex = j;
        }
      }
      temp.add(species.get(maxIndex));
      species.remove(maxIndex);
      i--;
    }
    species = (ArrayList)temp.clone();
  }
  void killStaleSpecies() {
    for (int i = 2; i< species.size(); i++) {
      if (species.get(i).staleness >= 15) {
        species.remove(i);
        i--;
      }
    }
  }
  void killBadSpecies() {
    float averageSum = getAvgFitnessSum();

    for (int i = 1; i< species.size(); i++) {
      if (species.get(i).averageFitness/averageSum * pop.size() < 1) {
        species.remove(i);
        i--;
      }
    }
  }
  float getAvgFitnessSum() {
    float averageSum = 0;
    for (Species s : species) {
      averageSum += s.averageFitness;
    }
    return averageSum;
  }

  void cullSpecies() {
    for (Species s : species) {
      s.cull(); 
      s.fitnessSharing();
      s.setAverage();
    }
  }


  void massExtinction() {
    for (int i =5; i< species.size(); i++) {
      species.remove(i);
      i--;
    }
  }

  void scoreup(int x){
    for(int i = 0; i< pop.size(); i++){
      if(!pop.get(i).dead){
        pop.get(i).score += x;
      }
    }
  }
}
