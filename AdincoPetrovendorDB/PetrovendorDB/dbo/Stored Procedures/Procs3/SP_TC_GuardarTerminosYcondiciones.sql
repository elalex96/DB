
CREATE PROCEDURE [dbo].[SP_TC_GuardarTerminosYcondiciones]
	@IdTerminosYCondiciones INT,
	@idProveedor INT,
	@Nombre VARCHAR(MAX),
	@documento NVARCHAR(max),
	@Comentario VARCHAR(MAX)
AS
BEGIN
	
	IF(@IdTerminosYCondiciones = 0)
	BEGIN
		INSERT INTO dbo.TC_TerminosYCondicionesDoc
		(
			IdProveedor,
			Nombre,
			Documento,
			Comentario,
			IsActivo
		)
		VALUES
		(   @idProveedor,   -- IdProveedor - int
			@nombre,  -- Nombre - varchar(max)
			@documento, -- Documento - nvarchar(max)
			@comentario,   -- Comentario - varchar(max)
			1
		)
		SELECT @@IDENTITY
	END
    ELSE
	BEGIN
		UPDATE dbo.TC_TerminosYCondicionesDoc
			SET Nombre = @nombre,
				Comentario = @comentario
			WHERE IdTerminosYCondiciones = @IdTerminosYCondiciones
	end

END
