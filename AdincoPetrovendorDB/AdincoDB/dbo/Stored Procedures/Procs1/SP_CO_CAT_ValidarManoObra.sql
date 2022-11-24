CREATE PROCEDURE [dbo].[SP_CO_CAT_ValidarManoObra] 
-- ============================================= 
@IdContrato   INT,
@IdUsuario    INT, 
@Id           INT
AS    
BEGIN       
    SET NOCOUNT ON; 
	IF EXISTS(SELECT * FROM [dbo].[CO_GastosRubro] WHERE IdGastoRubro = @Id AND Descripcion = 'MANO DE OBRA')
		BEGIN
			SELECT 1 AS Re;
		END
	ELSE
		BEGIN
			SELECT 0 AS Re;
		END
END