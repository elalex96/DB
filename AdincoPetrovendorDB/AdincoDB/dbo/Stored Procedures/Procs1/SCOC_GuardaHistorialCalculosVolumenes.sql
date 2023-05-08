
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20190123
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SCOC_GuardaHistorialCalculosVolumenes
    @idContrato INT,
    @MesReporte DATE,
    @Accion VARCHAR(100),
    @Comentarios NVARCHAR(MAX),
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO SCOC_HistorialAprobadosReiniciosCalculo (idContrato,
                                                         MesReporte,
                                                         Accion,
                                                         Comentarios,
                                                         CreadoPor,
                                                         CreadoEn,
                                                         ModificadoPor,
                                                         ModificadoEn)
    VALUES (@idContrato, @MesReporte, @Accion, @Comentarios, @idUsuario, GETDATE(), @idUsuario, GETDATE());
END;
