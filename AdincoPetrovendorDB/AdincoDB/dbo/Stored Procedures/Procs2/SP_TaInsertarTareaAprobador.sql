CREATE PROCEDURE [dbo].[SP_TaInsertarTareaAprobador] 
@IdTarea INT,
@Correo NVARCHAR(MAX)
AS
BEGIN
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 29-12-16
-- Description:	Inserta en la Tabla TareaAprobador de acuerdo al IdTarea y Correo resibidos de la parte Web
				-- pertenecientes a un IdTarea, IdUsuario e Id estatus por defaul de pendiente
-- =============================================
	SET NOCOUNT ON;

	DECLARE @IdEstatus INT = '1';
	DECLARE @IdUsuario INT;

-- LA ASIGNACION DE VARIABLES SE PUEDE HACER CON EL MISMO SELECT
	--SET @IdUsuario = (SELECT UsuarioID 
	--FROM AP_Usuario 
	--WHERE Usuario = @Correo)

	SELECT @IdUsuario = UsuarioID 
	FROM AP_Usuario 
	WHERE Usuario = @Correo

	INSERT INTO [dbo].[TaTareaAprobador]
	(IdTarea,
	IdUsuario,
	IdEstatus)

	VALUES
	(@IdTarea,
	@IdUsuario,
	@IdEstatus)
	
	SELECT @IdTarea
END
