-- =============================================
-- Author:		DANIEL AC
-- Create date: 09-04-18
-- Description:	Consultar las aprobaciones del usuario actual 
-- =============================================
-- Author:		Jose Roman
-- Create date: 15-08-2018
-- Description:	Se filtran las aprobaciones de tipo serial, donde los aprobadores con numero de secuencia menos aun no han aprobado la operacion			
-- =============================================
CREATE   PROCEDURE SP_PC_CD_ConsultarAprobacionesUsuario
    -- Add the parameters for the stored procedure here

    @IdUsuario INT,
    @IdProveedor INT,
    @IdTipoOperacion INT
  
AS
BEGIN
    
	--DECLARE @FlujoSerial TABLE(IdOperacion INT)

	--INSERT INTO @FlujoSerial
	--(
	--    IdOperacion
	--)
	--SELECT IdOperacion 
	--FROM dbo.FN_FlujoSerialNoAprobados (@IdUsuario, @IdProveedor, @IdTipoOperacion)

	SELECT 
		O.IdOperacion,
		PC.IdPedidoGeneral,
		O.Descripcion,
		E.Nombre,
		O.FechaRegistro,	
		P.RFC,
		PC.FolioComprobante
	FROM dbo.TA_Operacion O 
		INNER JOIN dbo.TA_Tarea T ON T.IdOperacion=O.IdOperacion AND O.IdTipoOperacion=@IdTipoOperacion 
		INNER JOIN dbo.FI_PedimentoComprobante PC ON PC.IdPedimentoComprobante=o.IdDocumento
		INNER JOIN dbo.TA_Estatus E ON E.IdEstatus = O.IdEstatusOperacion
		INNER JOIN dbo.S_Proveedor P ON P.IdProveedor=PC.IdSubcontratistaExportador
		--LEFT JOIN @FlujoSerial fs ON fs.IdOperacion = O.IdOperacion AND fs.IdOperacion IS NULL -- Se excluyen los flujos de tipo serial que no han sido aprobados por aprobadores superiores
	WHERE T.IdAprobador=@IdUsuario 
		AND PC.TipoOrigen='P_CECD' 
		AND PC.IdSubcontratistaImportador=@IdProveedor
		AND O.IdOperacion NOT IN (SELECT IdOperacion FROM dbo.FN_FlujoSerialNoAprobados(@IdUsuario,@IdProveedor,@IdTipoOperacion))
	ORDER BY PC.IdPedidoGeneral DESC

END;



