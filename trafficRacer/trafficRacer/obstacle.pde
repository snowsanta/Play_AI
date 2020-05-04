class Obstacle{
    int rad = 30, y = 0;
    ArrayList<Integer> ind = new ArrayList<Integer>();


    Obstacle(){
        int nos = 0;
        for(int i = 0; i < 3; i++){
            int temp = int(random(0,2));
            nos += temp;
            ind.add(temp);
            if(nos == 2){
              ind.add(0);
              break;
            }
        }
    }

    void show(){
        for(int b = 0; b < ind.size(); b++){
            if(ind.get(b) == 1){
                //circle(utils.getx(b), y, rad * 2);
                image(obstacleSprite, utils.getx(b) - rad, y);
                if(debug){
                    line(utils.getx(b) - (rad + int(car_width/2)), y, utils.getx(b) + rad + int(car_width/2), y);
                    line(utils.getx(b) - (rad + int(car_width/2)), y + rad, utils.getx(b) + rad + int(car_width/2), y + rad);
                    line(utils.getx(b) - (rad + int(car_width/2)), y - rad, utils.getx(b) + rad + int(car_width/2), y - rad);
                }
            }
        }
        y += speedObs;
    }

}
