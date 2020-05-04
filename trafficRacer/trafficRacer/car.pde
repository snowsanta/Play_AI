class Car{
    int x = int(gameWidth * .5), y = int(height*.85);
    int score = 0;

    Car(){
        
    }

    void steer(int str){
        if(str == 0){
            x = int(constrain(x - 10, leftLim, rightLim));
        }
        if(str == 1){
            x = int(constrain(x + 10, leftLim, rightLim));
        }
    }

    void show(){
        rectMode(CENTER);
        //rect(x, y, car_width, car_height);
        image(carSprite, x - car_width /2, y);
        if(debug){
            line(x, 0, x, height);
            line(0, y - int(car_height / 2), gameWidth, y - int(car_height / 2));
            line(0, y + int(car_height / 2), gameWidth, y + int(car_height / 2));
        }
    }
    
    boolean collided(){
        if(obsList.size() != 0){
            for(int i = 0; i < 4; i++){
                if(obsList.get(i).y + obsList.get(i).rad >= y - int(car_height / 2) - 10){
                    Obstacle temp = obsList.get(i);
                    for(int j = 0; j < temp.ind.size(); j++){
                        if(temp.ind.get(j) == 1 && abs(utils.getx(j) - x) <= temp.rad + int(car_width/2) && temp.y + temp.rad - (height * .02) > y - int(car_height / 2) && temp.y - temp.rad + (height * .02) < y + int(car_height / 2)){
                            return true;
                        }
                    }
                }
                else{
                    break;
                }
            }
        }
        return false;
    }


}
