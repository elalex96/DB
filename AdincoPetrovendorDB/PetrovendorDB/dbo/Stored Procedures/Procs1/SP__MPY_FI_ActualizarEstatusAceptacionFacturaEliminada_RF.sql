
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 16-08-17
-- Description:	Actualiza el estatus de aprobador y de la parobación general  
-- Author:		Daniel Cruz
-- Update date: 09-02-17
-- Description: Agregue validaciones  para diferentes casos de acuerdo a resultado de la aprobación general 
-- Author:		Alexander Gomez
-- Update date: 09-03-17
-- Description: se modifico la palabara finalizada por finalizado
-- Author:		Alexander Gomez
-- Update date: 15-03-17
-- Description: se modifico para el nuevo estatus de factura eliminada
-- =============================================
CREATE procedure [dbo].[SP__MPY_FI_ActualizarEstatusAceptacionFacturaEliminada_RF] --44,2221,116,''
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdUsuario INT,
    @IdAceptacionPedido INT,
    @Comentario NVARCHAR(MAX)

AS
BEGIN
			DECLARE @IdFactura INT;

			UPDATE MPY_MM_AceptacionFactura 
			SET [IdEstatusXML] = 6,
				[IdEstatusPDF] =6,
				IdEstatus = 6
			WHERE IdAceptacionPedido = @IdAceptacionPedido

			UPDATE dbo.MPY_FI_Aprobadores 
				SET EstatusAprobacion = NULL, 
					Comentario = NULL, 
					FechaEvaluacion = NULL 
			WHERE IdAceptacionPedido = @IdAceptacionPedido
			--- Obtener la información del flujo --- 

			SET @IdFactura =
			(
				SELECT IdFactura
				FROM MPY_MM_AceptacionFactura
				WHERE IdAceptacionPedido = @IdAceptacionPedido
			);



			UPDATE dbo.FI_Factura 
				SET IsEliminado = 1,
				    EliminadoPor = @IdUsuario,
					EliminadoEl  = GETDATE(),
					ComentarioEliminado = @Comentario 
			WHERE IdFactura = @IdFactura

			DECLARE @UUID NVARCHAR(MAX) = (SELECT UUID FROM dbo.FI_Factura WHERE IdFactura = @IdFactura)

			INSERT INTO dbo.FI_FacturaEliminada
			(
			    IdFactura,
			    FechaEliminada,
			    EliminadaPor,
			    UUID
			)
			VALUES
			(   @IdFactura,         -- IdFactura - int
			    GETDATE(), -- FechaEliminada - datetime
			    @IdUsuario,         -- EliminadaPor - int
			    @UUID        -- UUID - nvarchar(max)
			    )

			SELECT 'TRUE'
	
END;


