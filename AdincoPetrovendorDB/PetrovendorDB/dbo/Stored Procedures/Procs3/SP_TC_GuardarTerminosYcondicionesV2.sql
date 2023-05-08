-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TC_GuardarTerminosYcondicionesV2]
    @IdTerminosYCondiciones INT,
	@idProveedor INT,
	@Nombre VARCHAR(MAX),
	@documento NVARCHAR(MAX),
	@Comentario VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@IdTerminosYCondiciones = 0)
	BEGIN
		INSERT INTO dbo.TC_TerminosYCondicionesDocV2
		(
			IdProveedor,
			Nombre,
			Documento,
			Comentario,
			IsActivo,
			FechaRegistro
		)
		VALUES
		(   @idProveedor,   -- IdProveedor - int
			@nombre,  -- Nombre - varchar(max)
			@documento, -- Documento - nvarchar(max)
			@comentario,   -- Comentario - varchar(max)
			1,
			GETDATE()
		)
		SELECT @@IDENTITY
	END
    ELSE
	BEGIN
		UPDATE dbo.TC_TerminosYCondicionesDocV2
			SET Nombre = @nombre,
				Comentario = @comentario,
				Documento = @documento
			WHERE IdTerminosYCondiciones = @IdTerminosYCondiciones
			SELECT 'ACTUALIZADO'
	end

END

