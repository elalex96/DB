CREATE PROCEDURE [dbo].[SP_PR_EliminaAforo]
@IdAforo int
AS
BEGIN
	DELETE FROM dbo.PR_Aforo WHERE IdAforo= @IdAforo
END