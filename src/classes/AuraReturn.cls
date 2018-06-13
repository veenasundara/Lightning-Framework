/* Class:       AuraReturn
** Created by:  OpFocus (Veena Sundara-Heragu) on 6/12/18
** Description: Base return class for lightning component controllers.  All controllers should return
*               Objects that extend this class and set error values in the auraerror variable
*/
global virtual class AuraReturn
{
    @AuraEnabled global String auraerror;

    public void handleException(Exception e)
    {
        auraerror = e.getMessage();
    }
}