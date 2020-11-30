-- =============================================
-- Author:   Daniel AC
-- Create date: 26-09-2019
-- Description: Agregue cambio de referecias al s3 en los documentos adjuntos 
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConsultaCompraDirectaEdicion] ( @IdUsuario  INT,
                                                           @IdRegistro INT,
                                                           @IdFactura  INT )
AS
    BEGIN
        DECLARE @RazonSocial NVARCHAR (MAX);


        IF ( @IdFactura = 0 )
            BEGIN
                SET @RazonSocial = (   SELECT  TOP 1
                                               p.RazonSocial + ' '
                                               + ISNULL(p.RegimenCapital, '')
                                       FROM
                                               S_Proveedor     p
                                           INNER JOIN
                                               dbo.FI_Factura  f
                                                   ON f.Emisor = p.RFC
                                           INNER JOIN
                                               dbo.CO_Registro r
                                                   ON r.IdFactura = f.IdFactura
                                       WHERE
                                               r.IdRegistro = @IdRegistro );


                SELECT
                        linea.IdPresupuesto,
                        coRegistro.IdLineaPresupuestoMes,
                        fiFactura.ArchivoXML,
                        fiFactura.NombreXML,
                        fiFactura.PDF,                    --es de tipo varbinary
                        ISNULL(fiFactura.ArchivoPDF, ''), -- es byte array
                        fiFactura.SubTotal,
                        linea.IdActvidadHidrocarburo,
                        coRegistro.CuentaContable,
                        coRegistro.CentroCostos,
                        coRegistro.MontoRegistro,
                        coRegistro.InicioEjecucion,
                        coRegistro.FinEjecucion,
                        coRegistro.IdInstalacion,
                        coRegistro.Comentarios,
                        fiFactura.IdFactura,
                        ISNULL(centroCosto.CentroCosto, '') COLLATE DATABASE_DEFAULT
                        + ' | ' + CAST(a.id_Actividad AS NVARCHAR (50)) + ' | '
                        + a.DescripcionActividadPetrolera + ' | '
                        + sb.[id_Sub-actividad] + ' | '
                        + sb.SubactividadPetrolera + ' | ' + tp.id_Tarea + ' | '
                        + tp.TareaPetrolera + ' | '
                        + CAST(s.IdServicio AS NVARCHAR (MAX)) + ' | '
                        + s.NombreServicio,
                        cuentaSh.Descripcion,
                        cuentaContable.Descripcion,
                        instalacion.NombreInstalacion,
                        prove.RazonSocial,
                        CASE
                            WHEN @RazonSocial = ''
                                THEN
                                fiFactura.Emisor
                            WHEN @RazonSocial IS NULL
                                THEN
                                fiFactura.Emisor
                            ELSE
                                @RazonSocial
                        END                    AS ProveedorEmisor,
                        ISNULL(PG.IdPedido, 0) AS IdPedidoGeneral,
                        fiFactura.ComprobantePDFByte,
                        fiFactura.MontoConIva,
						ISNULL(fiFactura.IdLectorXMLSAT,1) AS IdLectorXMLSAT,
						REPLACE(ISNULL(fiFactura.ErroSAT,''),'Error SAT:','') AS ErrorSAT,
						ISNULL(ISAT.DireccionWeb,'') AS DireccionWeb,
						ISNULL(fiFactura.UUID,'') AS UUID,
						ISNULL(fiFactura.Emisor,'') AS RFC_Emisor,
						ISNULL(fiFactura.Receptor,'') AS RFC_Receptor 
                FROM
                        dbo.CO_Registro                     AS coRegistro
                    LEFT JOIN
                        dbo.FI_Factura                      AS fiFactura
                            ON fiFactura.IdFactura = coRegistro.IdFactura
                    LEFT JOIN
                        dbo.CC_CentroCosto                  centroCosto
                            ON centroCosto.IdCentroCosto = coRegistro.CentroCostos
                    LEFT JOIN
                        dbo.DG_CuentaContable               cuentaContable
                            ON cuentaContable.Id = coRegistro.CuentaContable
                    LEFT JOIN
                        Adinco.dbo.CO_LineaPresupuestoMes   linea
                            ON linea.IdLineaPresupuestoMes = coRegistro.IdLineaPresupuestoMes
                    LEFT JOIN
                        dbo.CO_CatalogoCuentaSH             cuentaSh
                            ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH
                    LEFT JOIN
                        Adinco.dbo.CO_Instalacion           instalacion
                            ON instalacion.IdInstalacion = coRegistro.IdInstalacion
                    LEFT JOIN
                        Adinco.dbo.CO_ActividadPetroleraCNH a
                            ON a.IdActividadPetrolera = linea.IdActividadPetrolera
                    LEFT JOIN
                        Adinco.dbo.CO_SubactividadPetrolera sb
                            ON sb.IdSubactividadPetrolera = linea.IdSubactividadPetrolera
                    LEFT JOIN
                        Adinco.dbo.CO_TareaPetrolera        tp
                            ON tp.IdTareaPetrolera = linea.IdTareaPetrolera
                    LEFT JOIN
                        Adinco.dbo.CO_Servicio              s
                            ON s.IdServicio = linea.IdServicio
                    LEFT JOIN
                        dbo.S_Usuario                       usuario
                            ON fiFactura.CreadoPor = usuario.IdUsuarioADINCO
                    LEFT JOIN
                        dbo.S_UsuarioProveedor              userProv
                            ON userProv.IdUsuario = usuario.IdUsuario
                    LEFT JOIN
                        dbo.S_Proveedor                     prove
                            ON prove.IdProveedor = userProv.IdProveedor
                    LEFT JOIN
                        dbo.CO_RegistroPedido               RP
                            ON RP.IdFactura = fiFactura.IdFactura
                    LEFT JOIN
                        dbo.MM_Pedido                       P
                            ON P.IdSolicitudPedido = RP.IdSolicitudPedido
                    INNER JOIN
                        dbo.TA_Operacion                    TAO
                            ON TAO.IdDocumento = fiFactura.IdFactura
                    INNER JOIN
                        dbo.MM_Pedidos                      PG
                            ON PG.IdIdentificador = fiFactura.IdFactura
                               AND PG.IdTipoPedido = 1
                               AND PG.IdProveedorCliente = TAO.IdProveedor
					LEFT JOIN dbo.InfoSAT ISAT ON ISAT.Id = 1
                WHERE
                        coRegistro.IdRegistro = @IdRegistro
                ORDER BY
                        coRegistro.IdRegistro DESC;
            END;
        ELSE
            BEGIN
                --tabla[1] Se Obtiene los soportes de la factura
				SELECT	idFactura AS IdFactura ,	--IdDocumento
						'' ,						--Descripcion
						'' AS Documento, 
						nombreArchivo AS NombreArchivo,
						Carpeta,
						Mime,
						Extension,
						Identificador,
						id
				  FROM	dbo.Pv_DocSoporte_CompraDirecta
				 WHERE	IdFactura = @IdFactura 
				 AND ISNULL(isEliminado,0)=0
            END;
    END;

