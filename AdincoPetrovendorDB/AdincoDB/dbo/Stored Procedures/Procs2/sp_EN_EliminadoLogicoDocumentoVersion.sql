-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20200416
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_EliminadoLogicoDocumentoVersion]--225,306594,3,10061
	@InstanciaEntregableId int,
	@IdLineaTiempo int,
	@DocumentoEntregableId INT,
	@idUsuario int,
	@idContrato int
AS
BEGIN
	SET NOCOUNT ON;
	set language  Spanish;
	DECLARE @TipoArchivo INT = 0;

	UPDATE 
		EN_DocumentoVersion
	SET
		Activo	=	0,
		ModificadoPor	=	@idUsuario,
		ModificadoEl	=	GETDATE()
	WHERE 
		idInstanciaEntregable	=	@InstanciaEntregableId
		AND	N_version	=	@IdLineaTiempo
		AND DocumentoEntregableId	=	@DocumentoEntregableId;	

	 SELECT @TipoArchivo	=	idTipoArchivo FROM EN_EntregableDocumento WHERE DocumentoEntregableId	=	@DocumentoEntregableId AND idInstanciaEntregable	=	@InstanciaEntregableId;

	 IF(@TipoArchivo	=	10002)
	 BEGIN
		UPDATE EN_HistorialAprobacionesLineaTiempo
		SET Activo	=	0 
		WHERE 
		idInstanciaEntregable	=	@InstanciaEntregableId 
		AND idTipoOperacion	=	7;

		UPDATE 
		EN_InstanciasEntregable
		SET BitContieneAcuse	=	0
		WHERE idInstanciaEntregable	=	@InstanciaEntregableId;
	 END

IF((SELECT COUNT(1) FROM EN_HistorialAprobacionesLineaTiempo WHERE idInstanciaEntregable	=	@InstanciaEntregableId AND IdLineaTiempo	= @IdLineaTiempo AND idTipoOperacion	=	9)	=	0)
	BEGIN

	INSERT INTO EN_HistorialAprobacionesLineaTiempo (
													IdLineaTiempo,
													idInstanciaEntregable,
													idContrato,
													Comentario,
													Rechazado,
													idTipoOperacion,
													CreadoPor,
													CreadoEn,
													ModificadoPor,
													ModificadoEn,
													Activo,
													ActualizadoByApp,
													URLRepositorio,
													ContieneURLRepositorio)
	VALUES
	(@IdLineaTiempo,@InstanciaEntregableId,@idContrato,'Fechas de eliminacion de documentos:'+ FORMAT (getdate(), 'dd-MM-yy hh:mm tt'),0,9,@idUsuario,GETDATE(),@idUsuario,GETDATE(),1,0,'En este paso no se ingresa URL',0);
END
ELSE
BEGIN
	UPDATE 
			EN_HistorialAprobacionesLineaTiempo
			SET 
				ModificadoPor	=	@idUsuario,
				ModificadoEn	=	GETDATE(),
				Comentario	=	Comentario	+ ',' + FORMAT (getdate(), 'dd-MM-yy hh:mm tt')
			WHERE 
				idInstanciaEntregable	=	@InstanciaEntregableId 
				AND IdLineaTiempo	= @IdLineaTiempo 
				AND idTipoOperacion	=	9
END
END