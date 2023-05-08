-- =============================================
-- Author:		Daniel Ac
-- Create date: 15-01-2018
-- Description:	consultar información de aprobadores de solcitud de pedido  
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_ConsultaAprobadoresSolicitudPedido] 
	-- Add the parameters for the stored procedure here

@IdSolicitudPedido INT,
@IdProveedor INT,
@IdContrato INT,
@FechaRegistro DATETIME,
@IdUsuario INT 

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
        

		SELECT S.Nombre, T.FechaCambioEstatus AS FechaRegistro,T.IdFirma AS FirmaAprobador
		FROM dbo.MM_SolicitudPedido AS SP
		INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento=SP.IdSolicitudPedido
		INNER JOIN dbo.TA_Tarea AS T ON T.IdOperacion	= O.IdOperacion
		INNER JOIN dbo.S_Usuario AS S ON S.IdUsuario=T.IdAprobador
		WHERE O.IdDocumento=@IdSolicitudPedido AND SP.IdProveedor=@IdProveedor	AND O.IdTipoOperacion=2
		ORDER BY S.Nombre ASC
        
     END;
