-- =============================================
-- Author:		Manuel Cruz
-- Create date: 03-01-17
-- Description:	De acuerdo al id de la tarea y correo, manda la estructura de texto plano del contenido del correo
				-- que se envia de acuerdo a la tarea asignada a cada aprobador, declarando y seleccionando los campos
				-- que se tienen que devolver a la parte web para que sean procesados
-- =============================================
CREATE PROCEDURE [dbo].[SP_TaAsignarPlantillaTarea] 
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
	SELECT @Asunto = C.Asunto FROM TaTarea T 
	join TaTipoTarea TT ON T.IdTipoTarea = TT.IdTipoTarea
	join TaTipoTareaCorreo TTC ON TT.IdTipoTarea = TTC.IdTipoTarea
	join S_Correo C ON  TTC.IdCorreo = C.IdCorreo
	WHERE IdTarea = @IdTarea and C.IdCorreo = @IdCorreo

	SELECT @CuerpoCorreoP1 = C.Cuerpo1 FROM TaTarea T 
	join TaTipoTarea TT ON T.IdTipoTarea = TT.IdTipoTarea
	join TaTipoTareaCorreo TTC ON TT.IdTipoTarea = TTC.IdTipoTarea
	join S_Correo C ON  TTC.IdCorreo = C.IdCorreo
	WHERE IdTarea = @IdTarea and C.IdCorreo = @IdCorreo

	SELECT @CuerpoCorreoP2 = C.Cuerpo2 FROM TaTarea T 
	join TaTipoTarea TT ON T.IdTipoTarea = TT.IdTipoTarea
	join TaTipoTareaCorreo TTC ON TT.IdTipoTarea = TTC.IdTipoTarea
	join S_Correo C ON  TTC.IdCorreo = C.IdCorreo
	WHERE IdTarea = @IdTarea and C.IdCorreo = @IdCorreo

	--CS *
	SELECT @IdCorreoServidor = CS.IdCorreoServidor FROM TaTarea T
	join TaTipoTareaCorreo TTC on T.IdTipoTarea = TTC.IdTipoTarea
	join S_CorreoServidor CS on TTC.IdCorreoServidor = CS.IdCorreoServidor
	WHERE IdTarea = @IdTarea

	SELECT @NombreRemitente = US.Nombre FROM TaTarea T
	join TaTareaAsignador TA ON T.IdTarea = TA.IdTarea
	join S_Usuario Us ON TA.IdUsuario = US.IdUsuario
	WHERE T.IdTarea = @IdTarea

	SET @Cuerpo = (SELECT REPLACE(@CuerpoCorreoP1, '(nombre)', @NombreRemitente))
	SELECT @Asunto AS Asunto, @Cuerpo AS Cuerpo1, @CuerpoCorreoP2 AS Cuerpo2, @IdCorreoServidor AS Servidor 
	FROM S_Correo 
	WHERE IdCorreo = @IdCorreo	
END


