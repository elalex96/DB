CREATE PROCEDURE [dbo].[sp_SIPAC_Procesar_IdPreciosTransfer_V2]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN

         -- =============================================
         -- Author: Manuel Cruz
         -- Create date: 07-04-17
         -- Description:        
         -- =============================================
         -- Modificado:		  Marcos Garcia
         -- Fecha Modificado: 2020-01-23
         -- Description:	  *Agregar Validacion de @IdPresupuesto = 0
         --					  *Agregar WITH (NOLOCK) en las tablas 
         -- =============================================
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.

         SET NOCOUNT ON;

         -- ES UNA MEJOR PRACTICA CREAR LA TABLA TEMPORAL DE FORMA EXPLICITA

         CREATE TABLE #EstudiosTransfer
         (IdEstudioPrecioTransfer INT, 
          IdContrato              INT, 
          SIPAC                   INT
         );

         -- Insert statements for procedure here

         INSERT INTO #EstudiosTransfer
         (IdEstudioPrecioTransfer, 
          IdContrato, 
          SIPAC
         )
                SELECT EPT.IdEstudioPrecioTransfer, 
                       EPT.IdContrato, 
                       ROW_NUMBER() OVER(ORDER BY EPT.FechaEstudio) AS SIPAC
                FROM FI_Transfer tr WITH(NOLOCK)
                     JOIN FI_TransferFactura tf WITH(NOLOCK) ON tr.IdTransferencia = tf.IdTransfer
                     JOIN FI_Factura F WITH(NOLOCK) ON tf.IdFactura = F.IdFactura
                     JOIN CO_Registro r WITH(NOLOCK) ON r.IdFactura = F.IdFactura
                     JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes
                     JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto
                     JOIN Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual
                     JOIN co_contrato c WITH(NOLOCK) ON AC.IdContrato = c.IdContrato
                     JOIN co_contratista con WITH(NOLOCK) ON c.idcontratista = con.idcontratista
                     JOIN FI_EstudioPreciosTransfer EPT WITH(NOLOCK) ON F.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
                WHERE c.IdContrato = @Contrato
                      AND r.IdEstado = 10004
                      AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes
                      AND r.CvTipoDocFacturacion = 1
                      AND ISNULL(CONVERT(INT, EPT.ProcesadoSIPAC), 0) = 0
                      AND p.IdPresupuesto = CASE
                                                WHEN @IdPresupuesto = 0
                                                THEN lpm.IdPresupuesto
                                                ELSE @IdPresupuesto
                                            END
                      --AND p.idpresupuesto = @IdPresupuesto

                      AND F.IdEstudioPrecioTransfer IS NOT NULL
                GROUP BY EPT.IdEstudioPrecioTransfer, 
                         EPT.IdContrato, 
                         EPT.FechaEstudio
                --
                UNION
                --
                SELECT EPT.IdEstudioPrecioTransfer, 
                       EPT.IdContrato, 
                       ROW_NUMBER() OVER(ORDER BY EPT.FechaEstudio) AS SIPAC
                FROM FI_Transfer tr WITH(NOLOCK)
                     JOIN FI_TransferFactura tf WITH(NOLOCK) ON tr.IdTransferencia = tf.IdTransfer
                     JOIN FI_PedimentoComprobante PC WITH(NOLOCK) ON tf.IdPedimentoComprobante = PC.IdPedimentoComprobante
                     JOIN CO_Registro r WITH(NOLOCK) ON r.IdPedimentoComprobante = PC.IdPedimentoComprobante
                     JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes
                     JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto
                     JOIN Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual
                     JOIN co_contrato c WITH(NOLOCK) ON AC.IdContrato = c.IdContrato
                     JOIN co_contratista con WITH(NOLOCK) ON c.idcontratista = con.idcontratista
                     JOIN FI_EstudioPreciosTransfer EPT WITH(NOLOCK) ON PC.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
                WHERE c.IdContrato = @Contrato
                      AND r.IdEstado = 10004
                      AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes
                      AND r.CvTipoDocFacturacion IN(2, 3)
                     AND ISNULL(CONVERT(INT, EPT.ProcesadoSIPAC), 0) = 0
                     AND lpm.IdPresupuesto = CASE
                                                 WHEN @IdPresupuesto = 0
                                                 THEN lpm.IdPresupuesto
                                                 ELSE @IdPresupuesto
                                             END
                     --AND p.idpresupuesto = @IdPresupuesto

                     AND PC.IdEstudioPrecioTransfer IS NOT NULL
                GROUP BY EPT.IdEstudioPrecioTransfer, 
                         EPT.IdContrato, 
                         EPT.FechaEstudio;
         -- ACTUALIZAR IdDocFacturacionSIPAC EN LA TABLA ESTUDIO PRECIOS TRANSFER
         UPDATE dbo.FI_EstudioPreciosTransfer
           SET
         --IdDocFacturacionSIPAC = CONCAT('PT', '-', LEFT('0'+CAST(MONTH(@Mes) AS VARCHAR(2)), 2)+CAST(YEAR(@Mes) AS CHAR(4)), '-', RIGHT('000000'+CAST(ET.SIPAC AS VARCHAR(6)), 6))
               IdDocFacturacionSIPAC = 'PT-'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'-'+RIGHT('000000'+CAST(ET.SIPAC AS VARCHAR(6)), 6)
         --,Nombre = 'PT_'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'_'+RIGHT('000000'+CAST(ET.SIPAC AS VARCHAR(6)), 6)+'.pdf'
         FROM FI_EstudioPreciosTransfer EPT
              JOIN #EstudiosTransfer ET ON EPT.IdEstudioPrecioTransfer = ET.IdEstudioPrecioTransfer
         WHERE EPT.IdEstudioPrecioTransfer = ET.IdEstudioPrecioTransfer;
         --EXEC sp_SIPAC_Procesar_IdPreciosTransfer_V2 3,'2017-03-01',3
         --sp_SIPAC_Procesar_IdPreciosTransfer_V2 10005,'2016-09-01',10036

     END;
