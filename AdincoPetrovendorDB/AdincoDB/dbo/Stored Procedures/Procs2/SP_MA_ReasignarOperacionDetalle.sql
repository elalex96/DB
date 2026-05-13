-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 30-01-2018
-- Description:	 SP que reasigna una tarea a otra aprobador
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MA_ReasignarOperacionDetalle] 
	-- Add the parameters for the stored procedure here
	@IdOperacion int,
	@IdOperacionDetalle INT, 
	@IdAprobador int, 
	@IdNuevoAprobador INT,
	@IdContrato INT = 0,
	@IdSubcontratista INT  =0,
	@FechaRegistro DATETIME = '30-01-2018 00:00',
	@Comentario NVARCHAR(MAX),
	@IdFirma NVARCHAR(300)
	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
	 
	 DECLARE @IdTareaNueva int  
	 DECLARE @Descripcion nvarchar(max)


	 SET NOCOUNT ON;
  
	 --- Agregar Tarea Usuario Nuevo --- 
	
		 INSERT INTO MA_OperacionDetalle(FechaRegistro,IdEstatus,Activo,IdAprobador,NoSecuencia,IdOperacion,IdContrato, IdSubcontratista, IsEliminado,Comentario)
		 SELECT GETDATE() AS FechaRegistro,OD.IdEstatus,OD.Activo,@IdNuevoAprobador AS IdAprobador,OD.NoSecuencia,OD.IdOperacion,OD.IdContrato, OD.IdSubcontratista, OD.IsEliminado,'' AS Comentario
		 FROM MA_OperacionDetalle AS OD 
		 WHERE OD.IdOperacionDetalle =  @IdOperacionDetalle AND OD.IdOperacion=@IdOperacion

		SET @IdTareaNueva = (SELECT @@IDENTITY)
						
	--- Cambiar Activo Aprobador Actual ---
	--- IdEstatus 7 --> Cancelado por reasignación

		 UPDATE MA_OperacionDetalle  SET Activo  = 0, IdEstatus = 7, FechaCambioEstatus=GETDATE(), Comentario=@Comentario , IdFirma=@IdFirma
		 WHERE IdOperacionDetalle = @IdOperacionDetalle

	 --- Agregar Evento Historial --- 

		 SET @Descripcion = 'El usuario '+
							(SELECT Nombre FROM dbo.AP_Usuario WHERE UsuarioID = @IdAprobador)+ 
							' ha reasignado la aprobación al usuario ' +
							(SELECT Nombre FROM dbo.AP_Usuario WHERE UsuarioID = @IdNuevoAprobador) 
							
		 INSERT INTO MA_HistorialOperacion(Detalle,IdOperacion,CreadoEl,IdEstadoFlujo)
		 VALUES(@Descripcion,@IdOperacion,GETDATE(),8)
		 ---# IdEstadoFlujo ---> 8 =Tarea Reasignada
    
	--- Enviar Datos del Nuevo Aprobador ---

		   SELECT Nombre, Usuario,@IdTareaNueva
		   FROM dbo.AP_Usuario
		   WHERE UsuarioID = @IdNuevoAprobador
    
 END



