-- =============================================
-- Author:		Manuel Cruz
-- Create date: 29-12-16
-- Description:	Inserta todos los datos en los campos correspondientes en el momento de crear una tarea para ser aprobada
-- =============================================
CREATE PROCEDURE [dbo].[sp_InsertarTarea] 
@NombreTarea nchar(200),
@IdTipoTarea int,
@Descripcion nvarchar(MAX),
@IdPrioridad int,
@IdOperacion int,
@IdUsuario int,
@IdVencimiento int 

AS
BEGIN

	DECLARE @IdTarea int;
	DECLARE @FechaRegistro as datetime = GETDATE()
	DECLARE @IdEstatus int = '1';
	DECLARE @Activo bit = '1';
	DECLARE @Correo nvarchar(MAX);

	SET NOCOUNT ON;

    INSERT INTO [dbo].[Tarea]
	(NombreTarea,
	IdTipoTarea,
	FechaRegistro,
	IdEstatus,
	Descripcion,
	IdPrioridad,
	Activo,
	IdOperacion,
	IdVencimiento)
	
	VALUES 
	(@NombreTarea,
	@IdTipoTarea,
	@FechaRegistro,
	@IdEstatus,
	@Descripcion,
	@IdPrioridad,
	@Activo,
	@IdOperacion,
	@IdVencimiento)
	
	SET @IdTarea = (select @@IDENTITY as INSERTADO)
	INSERT INTO dbo.TareaAsignador
	(IdTarea,
	IdUsuario)

	VALUES
	(@IdTarea,
	@IdUsuario)
	
	SET @Correo = (SELECT U.Correo FROM Usuario AS U WHERE U.IdUsuario = @IdUsuario)
	SELECT @IdTarea, @Correo

END

