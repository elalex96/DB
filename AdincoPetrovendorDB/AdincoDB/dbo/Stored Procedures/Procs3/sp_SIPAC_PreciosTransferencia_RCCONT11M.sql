CREATE PROCEDURE [dbo].[sp_SIPAC_PreciosTransferencia_RCCONT11M]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN

         -- =============================================
         -- Author: Manuel Cruz
         -- Create date: 04-04-17
         -- Description:  
         -- =============================================
         -- Modificado:		  Marcos Garcia
         -- Fecha Modificado: 2020-01-23
         -- Description:	  *Agregar Validacion de @IdPresupuesto = 0
         --					  *Agregar WITH (NOLOCK) en las tablas 
         -- =============================================
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         -- datepart(month,getdate()),datepart(year,getdate())

         SET NOCOUNT ON;

         /**/

         EXEC sp_SIPAC_Procesar_IdPreciosTransfer_V2 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;

         /**/

         SELECT
         --F.IdFactura,
         con.IdSipac, 
         c.IdRegFiducidiario, 
         CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(@Mes), MONTH(@Mes), 1)), 103) AS PeriodoReporte, 
         EPT.IdDocFacturacionSIPAC AS IdentificadorPrecioTransferencia,
         --EPT.Nombre,
         REPLACE(CONCAT(EPT.IdDocFacturacionSIPAC, '.pdf'), '-', '_') AS NombreExtensionArchivo, 
         EPT.FolioOperacion,
         CASE
             WHEN EPT.ProcesadoSIPAC = 1
             THEN 1
             ELSE 0
         END AS CargadoPeriodosAnteriores, 
         EPT.IdClasificacionDocumento
         FROM FI_Transfer tr WITH(NOLOCK)
              LEFT JOIN FI_TransferFactura tf WITH(NOLOCK) ON tr.IdTransferencia = tf.IdTransfer
              LEFT JOIN FI_Factura F WITH(NOLOCK) ON tf.IdFactura = F.IdFactura
              LEFT JOIN CO_Registro r WITH(NOLOCK) ON r.IdFactura = F.IdFactura
              LEFT JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes
              LEFT JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto
              LEFT JOIN Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual
              LEFT JOIN co_contrato c WITH(NOLOCK) ON tr.IdContrato = c.IdContrato
              LEFT JOIN co_contratista con WITH(NOLOCK) ON c.idcontratista = con.idcontratista
              LEFT JOIN FI_EstudioPreciosTransfer EPT WITH(NOLOCK) ON F.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
         WHERE c.IdContrato = @Contrato
               AND r.IdEstado = 10004
               AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes
               AND r.CvTipoDocFacturacion = 1
               AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
               AND p.IdPresupuesto = CASE
                                         WHEN @IdPresupuesto = 0
                                         THEN lpm.IdPresupuesto
                                         ELSE @IdPresupuesto
                                     END
               --AND p.idpresupuesto = @IdPresupuesto

               AND F.IdEstudioPrecioTransfer IS NOT NULL
         GROUP BY con.IdSipac, 
                  c.IdRegFiducidiario, 
                  EPT.IdDocFacturacionSIPAC, 
                  EPT.FolioOperacion, 
                  EPT.ProcesadoSIPAC, 
                  EPT.IdClasificacionDocumento, 
                  EPT.Nombre

         --,F.IdFactura
         --
         UNION
         --
         SELECT
         --PC.IdPedimentoComprobante,
         con.IdSipac, 
         c.IdRegFiducidiario, 
         CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(@Mes), MONTH(@Mes), 1)), 103) AS PeriodoReporte, 
         EPT.IdDocFacturacionSIPAC AS IdentificadorPrecioTransferencia,
         --EPT.Nombre,
         REPLACE(CONCAT(EPT.IdDocFacturacionSIPAC, '.pdf'), '-', '_') AS NombreExtensionArchivo, 
         EPT.FolioOperacion,
         CASE
             WHEN EPT.ProcesadoSIPAC = 1
             THEN 1
             ELSE 0
         END AS CargadoPeriodosAnteriores, 
         EPT.IdClasificacionDocumento
         FROM FI_Transfer tr WITH(NOLOCK)
              LEFT JOIN FI_TransferFactura tf WITH(NOLOCK) ON tr.IdTransferencia = tf.IdTransfer
              LEFT JOIN FI_PedimentoComprobante PC WITH(NOLOCK) ON tf.IdPedimentoComprobante = PC.IdPedimentoComprobante
              LEFT JOIN CO_Registro r WITH(NOLOCK) ON r.IdPedimentoComprobante = PC.IdPedimentoComprobante
              LEFT JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes
              LEFT JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto
              LEFT JOIN Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual
              LEFT JOIN co_contrato c WITH(NOLOCK) ON tr.IdContrato = c.IdContrato
              LEFT JOIN co_contratista con WITH(NOLOCK) ON c.idcontratista = con.idcontratista
              LEFT JOIN FI_EstudioPreciosTransfer EPT WITH(NOLOCK) ON PC.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
         WHERE c.IdContrato = @Contrato
               AND r.IdEstado = 10004
               AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes
               AND r.CvTipoDocFacturacion IN(2, 3)
              AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0
              AND p.IdPresupuesto = CASE
                                        WHEN @IdPresupuesto = 0
                                        THEN lpm.IdPresupuesto
                                        ELSE @IdPresupuesto
                                    END
              --AND p.idpresupuesto = @IdPresupuesto

              AND PC.IdEstudioPrecioTransfer IS NOT NULL
         GROUP BY con.IdSipac, 
                  c.IdRegFiducidiario, 
                  EPT.FolioOperacion, 
                  EPT.ProcesadoSIPAC, 
                  EPT.IdClasificacionDocumento, 
                  EPT.IdDocFacturacionSIPAC, 
                  EPT.Nombre;
         --,PC.IdPedimentoComprobante
         --EXEC sp_SIPAC_PreciosTransferencia_RCCONT11M 10005,'2016-09-01',10036

     END;
