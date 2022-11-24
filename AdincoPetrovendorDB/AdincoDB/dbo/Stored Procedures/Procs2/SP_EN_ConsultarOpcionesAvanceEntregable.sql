-- =============================================  
-- Author:   Daniel AC  
-- Create date: 15/10/2020  
-- Description:  Consultar las opciones de avances del entregable
-- ============================================= 
CREATE procedure [dbo].[SP_EN_ConsultarOpcionesAvanceEntregable]	

AS
BEGIN
	/*SP PARA GUARDAR EL GASTOS PROPORCIONAL DE LA NOTA DE CREDITO RELACIANDA A LOS DETALLES DE ACEPTACIÓN PEDIDO*/

	SELECT Clave, NombreClave, Porcentaje
	FROM dbo.EN_PorcentajeProgresoOpciones
	WHERE Clave <> 'SIN_INICIAR'
	ORDER BY NombreClave ASC
	 
END    

