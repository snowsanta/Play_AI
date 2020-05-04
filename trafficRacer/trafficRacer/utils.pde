class Utils{
    int getx(int pos){
        if(pos == 0){
            return int(gameWidth * .25);
        }
        if(pos == 1){
            return int(gameWidth * .5);
        }
        if(pos == 2){
            return int(gameWidth * .75);
        }
        return -1;
    }
}