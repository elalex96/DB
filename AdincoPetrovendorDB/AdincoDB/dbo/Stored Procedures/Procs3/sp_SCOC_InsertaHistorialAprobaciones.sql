-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180929
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCOC_InsertaHistorialAprobaciones]
    @idContrato INT,
    @MesReporte DATE,
	@IdPermiso INT,
    @idUsuario INT,
	@Comentarios varchar(2000),
	@Rechazado bit
AS
BEGIN

    SET NOCOUNT ON;

	INSERT INTO dbo.SCOC_HistorialAprobaciones (IdContrato,
	                                            MesReporte,
	                                            IdPermiso,
	                                            UsuarioID,
	                                            Comentarios,
	                                            FecMovto,
	                                            Rechazado)
	VALUES (@idContrato, -- IdContrato - int
	       @MesReporte, -- MesReporte - date
	        @IdPermiso, -- IdPermiso - int
	        @idUsuario, -- UsuarioID - int
	        @Comentarios, -- Comentarios - varchar(2000)
	        GETDATE(), -- FecMovto - datetime
	        @Rechazado -- Rechazado - bit
	    )
	END;