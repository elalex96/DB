CREATE PROCEDURE [dbo].[SP_ObtenPorcentajePorRegistroId]
@IdContrato  INT,     
@IdUsuario     INT,
@RegistroId     INT
AS    
     BEGIN       
         SET NOCOUNT ON;
		 SELECT Porcentaje FROM [CO_RegistroMarkup] WHERE GastoId = @RegistroId
		 
END