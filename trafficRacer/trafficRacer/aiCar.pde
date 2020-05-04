class AiCar extends Car{
    float fitness;
    boolean dead = false;
    int gen, inNos = 7, outNos = 2;

    Genome brain;
    float[] vision = new float[inNos];
    float[] decision = new float[outNos];
    
    AiCar(){
        brain = new Genome(inNos, outNos);
    }

    void look(){
        vision[0] = x;
        vision[1] = 0;
        vision[2] = 0;
        vision[3] = 0;
        vision[4] = 0;
        vision[5] = 0;
        vision[6] = 0;

        if(obsList.size() != 0){
            for(int i = 0; i < obsList.size(); i++){
                if(obsList.get(i).y + obsList.get(i).rad > y - int(car_height / 2)){
                    vision[1] = float(obsList.get(i).ind.get(0));
                    vision[2] = float(obsList.get(i).ind.get(1));
                    vision[3] = float(obsList.get(i).ind.get(2));
                }
                else{
                    vision[4] = float(obsList.get(i).ind.get(0));
                    vision[5] = float(obsList.get(i).ind.get(1));
                    vision[6] = float(obsList.get(i).ind.get(2));
                    break;
                }
            }
        }
    }

    void doStuff(){
        decision = brain.feedForward(vision);
        if(max(decision[0], decision[1]) < .7){
            if(decision[0] > decision[1]){
                steer(0);
            }
            else{
                steer(1);
            }
        }
    }

    AiCar clone(){
        AiCar clone = new AiCar();
        clone.brain = brain.clone();
        clone.fitness = fitness;
        clone.brain.generateNetwork();
        clone.gen = gen;
        return clone;
    }

    void calculateFitness(){
        fitness = score * score;
    }

    AiCar crossover(AiCar parent2){
        AiCar child = new AiCar();
        child.brain = brain.crossover(parent2.brain);
        child.brain.generateNetwork();
        return child;
    }
}
