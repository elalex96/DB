-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <07-06-2019>
-- Description:	<Registro del historial de aprobacion o edicion de carta cn>
-- =============================================
CREATE PROCEDURE [dbo].[SP_CN_EditarCartaCN]
	-- Add the parameters for the stored procedure here
	@IdAceptacionCartaCN INT,
	@IdUsuario INT,
	@IdProveedor INT,
	@MPY BIT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF @MPY = 1
	BEGIN

		SET @IdAceptacionCartaCN = (SELECT TOP 1 IdAceptacionCartaPCN FROM dbo.MPY_MM_AceptacionCartaPCN WHERE IdAceptacionPedido = @IdAceptacionCartaCN ORDER BY CreadoEl DESC);

	    UPDATE dbo.MPY_MM_AceptacionCartaPCN
			SET IdEstatus = 3,
				FechaEvaluacion = GETDATE(),
				IdUsuarioEvaluador = @IdUsuario,
				ComentarioEvaluador = 'RECHAZO AUTOMATICO PARA EDICION DE CONCEPTOS Y CALCULO DE LA CARTA DE CONTENIDO NACIONAL',
				Editado = 1
		WHERE IdAceptacionCartaPCN = @IdAceptacionCartaCN;

	END
	ELSE
	BEGIN
		
		SET @IdAceptacionCartaCN = (SELECT TOP 1 IdAceptacionCartaPCN FROM dbo.MM_AceptacionCartaPCN WHERE IdAceptacionPedido = @IdAceptacionCartaCN ORDER BY CreadoEl DESC);

	    UPDATE [dbo].[MM_AceptacionCartaPCN]
		SET [IdEstatus]= 3,
		[ComentarioEvaluador] = 'RECHAZO AUTOMATICO PARA EDICION DE CONCEPTOS Y CALCULO DE LA CARTA DE CONTENIDO NACIONAL',
		[FechaEvaluacion] =getdate(),
		[IdUsuarioEvaluador] = @IdUsuario,
		Editado = 1
		WHERE [IdAceptacionCartaPCN]=@IdAceptacionCartaCN;


	END;

	SELECT 'SUCCESS' AS RESPONSE

	
END
