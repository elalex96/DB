-- =============================================
-- Author:		Alexander Gomez
-- Create date: 10-06-2019
-- Description:	consula dee carta cn editada
-- =============================================
CREATE PROCEDURE [dbo].[SP_CN_VerificacionCartaCNEditada] 
	-- Add the parameters for the stored procedure here
	@IdAceptacionCartaCN INT,
	@MPY BIT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IdAceptacionPedido INT;
	DECLARE @Editada BIT;
	DECLARE @CONT INT;

	IF @MPY = 1
	BEGIN
		SET @IdAceptacionPedido = (SELECT TOP 1 IdAceptacionPedido FROM dbo.MPY_MM_AceptacionCartaPCN  WHERE IdAceptacionCartaPCN = @IdAceptacionCartaCN);

		SET @CONT = (SELECT COUNT(IdAceptacionCartaPCN) FROM dbo.MPY_MM_AceptacionCartaPCN WHERE IdAceptacionPedido = @IdAceptacionPedido AND Editado = 1);

		IF @CONT > 0
		BEGIN
		    SET @Editada = 1;
		END

	END
	ELSE
	BEGIN
	    SET @IdAceptacionPedido = (SELECT TOP 1 IdAceptacionPedido FROM dbo.MM_AceptacionCartaPCN  WHERE IdAceptacionCartaPCN = @IdAceptacionCartaCN);

		SET @CONT = (SELECT COUNT(IdAceptacionCartaPCN) FROM dbo.MM_AceptacionCartaPCN WHERE IdAceptacionPedido = @IdAceptacionPedido AND Editado = 1);

		IF @CONT > 0
		BEGIN
		    SET @Editada = 1;
		END
	END

	SELECT @Editada AS Editada
END
