-- =============================================
-- Author:		Manuel Cruz
-- Create date: 5-01-17
-- Description:	Inserta en la tabla Documento el nombredocuemtno y la ruta, y en TareDocuemtno IdTarea, IdDocumento, IdUsuario
				-- IdTipoUsuario para llevar el registro de los archivos que suben tanto el asignador como los aprobadores de las
				-- tareas en especifico
-- =============================================
CREATE PROCEDURE [dbo].[SP_TaInsertarDocumento] 

	@IdTarea int,
	@IdUsuario int,
	@NombreDocumento nvarchar(MAX),
	@RutaDocumento nvarchar(MAX),
	@IdTipoUsuario int
	 
AS
BEGIN
	DECLARE @IdDocumento int;
	SET NOCOUNT ON;
     
	 INSERT INTO TaDocumento (NombreDocumento,RutaDocumento)
	 VALUES(@NombreDocumento,@RutaDocumento)

     SET @IdDocumento = (select @@IDENTITY as INSERTADO)

	 INSERT INTO TaTareaDocumento (IdTarea,IdDocumento,IdUsuario,IdTipoUsuario)
	 VALUES(@IdTarea,@IdDocumento,@IdUsuario,@IdTipoUsuario)
	 
END


