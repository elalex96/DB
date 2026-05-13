-- =============================================
-- Author:		Reyna Olvera
-- Create date: 11/10/2019
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[sp_PR_EliminacionFormatosProduccion] --10061,3
    @IdFormatoProduccionAWS INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE PR_FormatoProduccionAWS
    WHERE IdFormatoProduccionAWS = @IdFormatoProduccionAWS
END;
