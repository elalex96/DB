-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07/06/2018
-- Description:	Solo checa que tipo de documento es
-- =============================================
CREATE PROCEDURE [dbo].[FI_ChecaTipoDocumento]
    
	@IdRegistro INT
AS
BEGIN
	
	SET NOCOUNT ON;
  
DECLARE @TipoArchivo INT;
DECLARE @IdDoc INT;
--
SELECT CvTipoDocFacturacion
FROM dbo.CO_Registro
WHERE IdRegistro = @IdRegistro;
--
END

