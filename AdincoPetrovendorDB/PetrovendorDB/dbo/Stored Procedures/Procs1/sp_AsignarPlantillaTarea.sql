-- =============================================
-- Author:		Manuel Cruz
-- Create date: 03-01-17
-- Description:	De acuerdo al id de la tarea y correo, manda la estructura de texto plano del contenido del correo
				-- que se envia de acuerdo a la tarea asignada a cada aprobador, declarando y seleccionando los campos
				-- que se tienen que devolver a la parte web para que sean procesados
-- =============================================
CREATE PROCEDURE [dbo].[sp_AsignarPlantillaTarea] 
	-- Add the parameters for the stored procedure here
	@IdTarea INT,
	@IdCorreo INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	declare @NombreRemitente nvarchar(MAX)
	declare @Asunto nvarchar(MAX)
	declare @CuerpoCorreoP1 nvarchar(MAX)
	declare @CuerpoCorreoP2 nvarchar(MAX)
	declare @Cuerpo nvarchar(MAX)
	declare @IdCorreoServidor int

	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @Asunto = C.Asunto FROM Tarea T 
	join TipoTarea TT ON T.IdTipoTarea = TT.IdTipoTarea
	join TipoTareaCorreo TTC ON TT.IdTipoTarea = TTC.IdTipoTarea
	join Correo C ON  TTC.IdCorreo = C.IdCorreo
	WHERE IdTarea = @IdTarea and C.IdCorreo = @IdCorreo

	SELECT @CuerpoCorreoP1 = C.CuerpoCorreoP1 FROM Tarea T 
	join TipoTarea TT ON T.IdTipoTarea = TT.IdTipoTarea
	join TipoTareaCorreo TTC ON TT.IdTipoTarea = TTC.IdTipoTarea
	join Correo C ON  TTC.IdCorreo = C.IdCorreo
	WHERE IdTarea = @IdTarea and C.IdCorreo = @IdCorreo

	SELECT @CuerpoCorreoP2 = C.CuerpoCorreoP2 FROM Tarea T 
	join TipoTarea TT ON T.IdTipoTarea = TT.IdTipoTarea
	join TipoTareaCorreo TTC ON TT.IdTipoTarea = TTC.IdTipoTarea
	join Correo C ON  TTC.IdCorreo = C.IdCorreo
	WHERE IdTarea = @IdTarea and C.IdCorreo = @IdCorreo

	--CS *
	SELECT @IdCorreoServidor = CS.IdCorreoServidor FROM Tarea T
	join TipoTareaCorreo TTC on T.IdTipoTarea = TTC.IdTipoTarea
	join CorreoServidor CS on TTC.IdCorreoServidor = CS.IdCorreoServidor
	WHERE IdTarea = @IdTarea

	SELECT @NombreRemitente = US.Nombre +' '+ US.ApellidoPaterno +' '+ US.ApellidoMaterno FROM Tarea T
	join TareaAsignador TA ON T.IdTarea = TA.IdTarea
	join Usuario Us ON TA.IdUsuario = US.IdUsuario
	WHERE T.IdTarea = @IdTarea

	SET @Cuerpo = (SELECT REPLACE(@CuerpoCorreoP1, '<nombre>', @NombreRemitente))
	SELECT @Asunto AS Asunto, @Cuerpo AS Cuerpo1, @CuerpoCorreoP2 AS Cuerpo2, @IdCorreoServidor AS Servidor FROM Correo WHERE IdCorreo = @IdCorreo	
END

