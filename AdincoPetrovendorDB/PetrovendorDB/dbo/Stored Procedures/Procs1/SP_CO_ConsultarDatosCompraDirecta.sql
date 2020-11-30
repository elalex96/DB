-- =============================================
-- Author:		Daniel AC
-- Create date: 15-09-17
-- Description:	Consultar Pedido Detalle  Encabezado
-- =============================================
-- Author:		Alexander Gomez 
-- Update date: 12/03/2018
-- Description:	Se removio el campo de nombre de vialidad
-- =============================================
-- Author:		Jose Roman 
-- Update date: 24-10-2018
-- Description:	Se agrega la consulta de la linea de presupuesto
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 04/01/2019
-- Description:	Se modifico el left join que consulta el area contratual (estaba con la linea de presupuesto y es con la factura)
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 29/04/2019
-- Description:	Se modifico el left join con la tabla de linea de presupuesto mes a Adinco
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 02/05/2020
-- Description:	Se agrego la cuenta bancaria concatenada en el comentario
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultarDatosCompraDirecta]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdRegistro INT,
    @IdFactura INT,
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@IdFechaRegistro DATETIME = NULL

AS
BEGIN

    DECLARE @PROVEDORACTUAL VARCHAR(MAX),
            @RFCOperador NVARCHAR(50),
            @TelefonoOperadora NVARCHAR(30);

    SELECT @PROVEDORACTUAL = CONCAT(ISNULL(RazonSocial, ''), ' ', ISNULL(RegimenCapital, '')),
           @RFCOperador = RFC,
           @TelefonoOperadora = Telefono
    FROM S_Proveedor
    WHERE IdProveedor = @IdProveedor;
	

    DECLARE @PROVEDORACTUALDOMICILIO VARCHAR(MAX)
        =   (
                SELECT CONCAT(
								'Calle.',
                                 DF.Calle,
                                 ' ',
                                 'N°Interior.',
                                 DF.NoExterior,
                                 ' ',
                                 'N°Exterior.',
                                 DF.NoInterior,
                                 ' ',
								 'Col.',
                                 ISNULL(DF.Colonia, ''),
                                 ' ',
                                 'CP.',
                                 DF.CodigoPostal
                             )
                FROM S_Proveedor AS PV
                    INNER JOIN DG_Domicilio AS DF
                        ON DF.IdProveedor = PV.IdProveedor
                WHERE PV.IdProveedor = @IdProveedor
                      AND DF.IdTipoDomicilio = 1
                      AND DF.Activo = 1
            );

    SELECT

        --Operadora 
        @PROVEDORACTUAL AS NombreOperador,
        @PROVEDORACTUALDOMICILIO AS DireccionFisicaOperador,
        @RFCOperador AS RFCOperador,
        U.Nombre AS ContactoOperadora,
        U.Correo AS ContactoOperadoraCorreo,
        @TelefonoOperadora AS TelefonoOperadora,
        PG.IdPedido AS OrdenCompra,
        O.FechaRegistro,
        contrato.NumeroContrato,
        areaContractual.NombreAreaContractual AS CampoBloque,
        U.Nombre AS Solicitante,
        centroCostoOp.CentroCosto AS CentroCostoOperadora,

        --Datos del Proveedor
        ISNULL(PV.RazonSocial, '') + ' ' + ISNULL(PV.RegimenCapital, '') AS Proveedor,
        F.Emisor AS RFCProveedor,
        (CASE
             WHEN DG.IdDomicilio IS NOT NULL THEN
                 CONCAT(
							'Calle.',
                           DG.Calle,
                           ' ',
                           'N°Interior.',
                           DG.NoExterior,
                           ' ',
                           'N°Exterior.',
                           DG.NoInterior,
						   'Col.',
                           ISNULL(DG.Colonia, ''),
                           ' ',
                           'CP.',
                           DG.CodigoPostal
                       )
             ELSE
                 ''
         END
        ) AS DomicilioProveedor,
        --Especificaciones de la compra
        '' AS TipoCompra,
        TM.TipoMonedaCorto,
        @TelefonoOperadora AS CompraTelefono,
        U.Correo AS CompraMail,

        --Materiales y Elaboro
        F.SubTotal,
        '' AS CantidadConLetra,
        C.IdRegistro,
        F.MontoConIva,
        0 AS IVA,
        F.Descuento,
        PR.Nombre,
        U.Nombre AS Asignador,
        F.CondicionesDePago,
        U.Nombre AS Elaboro,
        F.CreadoEn AS ElaboroFecha,
        CONCAT('Cuenta Bancaria: ' + PG.CuentaBancaria + ' - ',c.Comentarios) AS ComentariosComprador,
		o.IdFirma,
	    CAST(a.id_Actividad AS NVARCHAR(50)) + ' | ' + a.DescripcionActividadPetrolera + ' | ' + sb.[id_Sub-actividad] + ' | ' +  sb.SubactividadPetrolera + ' | ' + tp.id_Tarea + ' | ' + tp.TareaPetrolera + ' | ' + CAST(s.IdServicio AS NVARCHAR(max)) + ' | ' + s.NombreServicio AS LineaPresupuesto
    FROM dbo.FI_Factura F
        INNER JOIN dbo.CO_Registro C
            ON C.IdFactura = F.IdFactura
        INNER JOIN dbo.S_Proveedor PV
            ON PV.RFC = F.Emisor
        INNER JOIN dbo.TA_Operacion O
            ON O.IdDocumento = F.IdFactura
        INNER JOIN dbo.TA_Estatus E
            ON E.IdEstatus = O.IdEstatusOperacion
        INNER JOIN dbo.PV_TipoMoneda TM
            ON TM.IdMoneda = F.IdMoneda
        INNER JOIN dbo.TA_Prioridad PR
            ON PR.IdPrioridad = O.IdPrioridad
        LEFT JOIN dbo.S_Usuario U
            ON U.IdUsuario = O.IdAsignador
        LEFT JOIN dbo.MM_Pedidos PG
            ON PG.IdIdentificador = O.IdDocumento
               AND PG.IdTipoPedido = 1
               AND O.IdProveedor = PG.IdProveedorCliente
        LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes lpm
            ON lpm.IdLineaPresupuestoMes = C.IdLineaPresupuestoMes
        LEFT JOIN Adinco.dbo.CO_Area area
            ON area.IdArea = lpm.IdArea
        LEFT JOIN Adinco.dbo.CO_Contrato contrato
            ON contrato.IdContrato = F.IdContrato
        LEFT JOIN Adinco.dbo.CO_AreaContractual areaContractual
            ON areaContractual.IdAreaContractual = contrato.IdAreaContractual
        LEFT JOIN dbo.CC_CentroCosto centroCostoOp
            ON centroCostoOp.IdCentroCosto = C.CentroCostos
        LEFT JOIN dbo.DG_Domicilio AS DG
            ON DG.IdProveedor = PV.IdProveedor
               AND DG.IdTipoDomicilio = 1
               AND DG.Activo = 1
		LEFT JOIN Adinco.dbo.CO_ActividadPetroleraCNH a ON a.IdActividadPetrolera = lpm.IdActividadPetrolera
		LEFT JOIN adinco.dbo.CO_SubactividadPetrolera sb ON sb.IdSubactividadPetrolera = lpm.IdSubactividadPetrolera
		LEFT JOIN Adinco.dbo.CO_TareaPetrolera tp ON tp.IdTareaPetrolera = lpm.IdTareaPetrolera
		LEFT JOIN Adinco.dbo.CO_Servicio s ON s.IdServicio = lpm.IdServicio
    WHERE F.IdFactura = @IdFactura
          AND C.IdRegistro = @IdRegistro
          AND O.IdTipoOperacion = 14;
		  
END;
 

