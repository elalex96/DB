-- =============================================
-- Author:		Reyna Olvera
-- =============================================
CREATE PROCEDURE [dbo].[sp_JOA_ObtenArea]--3,10061,0
    @IdContrato INT,
    @IdUsuario INT,
	@SocioId	int = 0
AS
BEGIN

    SET NOCOUNT ON;

    SELECT idArea,
           NombreArea
      FROM en_area
     WHERE idcontrato = @IdContrato;
END;


