-- =============================================
-- Author: Daniel Ac
-- Create date: 20-11-2020
-- Description: Se agrego configuración estatica de reporte para ENI- TAB DE CN
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeClavesTablero_ENI]
    @idContrato INT,
	@idUsuario INT,
    @IdRol INT,
	@IdTableroContrato INT
AS
BEGIN
    SET NOCOUNT ON;
    --ESTE CONFIGURACIÓN ES ESTATICA PARA ENI --SE DEBE MOSTRAR EL TABLERO EN CN

  --https://www.smps-adinco.com/#/site/Eni/views/EniLC_15962201107300/LocalContent 
	SELECT      Workbook='EniLC_15962201107300',
				Sheet='LocalContent',
				Tabs='no',
				Site='Eni',
				SiteT='/t/Eni',
				DNS='https://www.smps-adinco.com/trusted/',
				HeightPX=1110,
				Parametros='',
				Toolbar='no',
				UserTableau='admin' 

END;



