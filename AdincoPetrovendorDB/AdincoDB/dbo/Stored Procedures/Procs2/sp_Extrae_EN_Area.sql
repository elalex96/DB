-- =============================================
-- Author:		Reyna Olvera
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_Extrae_EN_Area]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN

    SET NOCOUNT ON;
    SELECT idArea,
           NombreArea
      FROM en_area
     WHERE idcontrato = @IdContrato;
END;