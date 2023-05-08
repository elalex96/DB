-- =============================================
-- Author:	Daniel AC
-- Create date: <30/08/2022>
-- Description:	<Administrar las notificaciones registradas para pagina default petrovendor >
-- =============================================
CREATE PROCEDURE dbo.APP_AdministrarNotificacionDefault
@TipoConsulta NVARCHAR(50),
@Id INT = NULL,
@ContratoId INT = NULL,
@ProveedorId  INT = NULL,
@Titulo NVARCHAR(200) = NULL,
@Mensaje NVARCHAR(MAX) = NULL,
@FechaInicio DATETIME = NULL,
@FechaFinalizacion DATETIME = NULL,
@Activo BIT = NULL,
@UsuarioId INT = NULL
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Antes NVARCHAR(MAX),@Despues NVARCHAR(MAX)

IF @TipoConsulta ='CONSULTAR_TODOS'
BEGIN 
	 SELECT 
	 Id,
	 ContratoId,	
	 Titulo,
	 Mensaje,
	 FechaInicio,
	 FechaFinalizacion,
	 Activo,	
	 CreadoEl,
	 ModificadoEl	
	 FROM APP_NotificacionesDefault
	 ORDER BY Id ASC
 END 

 IF @TipoConsulta ='INSERTAR'
 BEGIN
	INSERT INTO APP_NotificacionesDefault(ContratoId,Titulo,Mensaje,CreadoEl,FechaInicio,FechaFinalizacion,Activo)
	VALUES(@ContratoId,@Titulo,@Mensaje,GETDATE(),@FechaInicio,@FechaFinalizacion,@Activo)
 END 

 IF @TipoConsulta ='ACTUALIZAR'
 BEGIN
	SET @Antes = (SELECT Id,ContratoId,Titulo,Mensaje,CreadoEl,FechaInicio,FechaFinalizacion,Activo
					FROM APP_NotificacionesDefault
					WHERE Id=@Id
					FOR JSON AUTO);

	UPDATE APP_NotificacionesDefault
	SET ContratoId=@ContratoId,	
	Titulo=@Titulo,
	Mensaje=@Mensaje,	
	ModificadoEl=GETDATE(),
	FechaInicio=@FechaInicio,
	FechaFinalizacion=@FechaFinalizacion,
	Activo=@Activo
	WHERE Id=@Id

	SET @Despues = (SELECT Id,ContratoId,Titulo,Mensaje,CreadoEl,FechaInicio,FechaFinalizacion,Activo
					FROM APP_NotificacionesDefault
					WHERE Id=@Id
					FOR JSON AUTO);


	INSERT INTO dbo.BitacoraErrores (HResult, Mensaje, StackTrace, IdUsuario, IdProveedor, FechaRegistro)
	VALUES
	(   -1,    -- HResult - int
		'EDICIÓN-APP_NotificacionesDefault',    -- Mensaje - nvarchar(max)
		CONCAT('{"ANTES": ',ISNULL(@Antes,'-'), ', "DESPUES":', ISNULL(@Despues,'-'),'}'), -- StackTrace - nvarchar(max)
		0,  -- IdUsuario - int
		0, 
		GETDATE())
 END 


  IF @TipoConsulta ='ELIMINAR'
 BEGIN

	SET @Antes = (SELECT Id,ContratoId,Titulo,Mensaje,CreadoEl,FechaInicio,FechaFinalizacion,Activo
					FROM APP_NotificacionesDefault
					WHERE Id=@Id
					FOR JSON AUTO);

	DELETE FROM APP_NotificacionesDefault
	WHERE Id=@Id

	 INSERT INTO dbo.BitacoraErrores (HResult, Mensaje, StackTrace, IdUsuario, IdProveedor, FechaRegistro)
	VALUES
	(   -1,    -- HResult - int
		'ELIMINACIÓN-APP_NotificacionesDefault',    -- Mensaje - nvarchar(max)
		CONCAT('{"REGISTRO": ',ISNULL(@Antes,'-'),'}'), -- StackTrace - nvarchar(max)
		0,  -- IdUsuario - int
		0, 
		GETDATE())

 END 


 IF @TipoConsulta='CONSULTAR_CONTRATOS'
 BEGIN 

	SELECT C.IdContrato as ContratoId,	
	CONCAT(C.IdContrato,'- ', C.NumeroContrato, '-',AC.NombreAreaContractual)  AS Contrato	
	from S_UsuarioProveedor UP
	JOIN Adinco..CO_Contrato C
		ON UP.idContrato = C.IdContrato
	JOIN Adinco..CO_AreaContractual AC
		ON C.IdAreaContractual=AC.IdAreaContractual	
	WHERE UP.idContrato is not null
	GROUP by C.idContrato, AC.NombreAreaContractual, C.NumeroContrato
	ORDER BY AC.NombreAreaContractual DESC

 END 
END;




