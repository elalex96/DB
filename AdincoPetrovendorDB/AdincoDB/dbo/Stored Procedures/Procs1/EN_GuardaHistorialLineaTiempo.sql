-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019/02/14
-- Description:	Guarda Historial completo de las instancias

-- Update date: 2019/06/24
-- Update description: Se agregó el nuevo caracter de modificado por la app 
-- =============================================
CREATE PROCEDURE [dbo].[EN_GuardaHistorialLineaTiempo]--12,10900,10061,3,'',0,2
    @idLineaTiempo INT,
    @InstanciaEntregableId INT,
    @idUsuario INT,
    @idContrato INT,
    @Comentario VARCHAR(5000)='',
    @Rechazado BIT,
    @idTipoAprobador INT,
	@ActualizadoByApp bit = 0,
	@URLRepositorio VARCHAR(5000)='',
	@ContieneURLRepositorio BIT=0
AS
BEGIN
    SET NOCOUNT ON;



    INSERT INTO EN_HistorialAprobacionesLineaTiempo
    (
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
		ContieneURLRepositorio
    )
    VALUES
    (@idLineaTiempo, @InstanciaEntregableId, @idContrato, @Comentario, @Rechazado, @idTipoAprobador, @idUsuario,
     GETDATE(), @idUsuario, GETDATE(), 1, @ActualizadoByApp,@URLRepositorio,@ContieneURLRepositorio);

END;



