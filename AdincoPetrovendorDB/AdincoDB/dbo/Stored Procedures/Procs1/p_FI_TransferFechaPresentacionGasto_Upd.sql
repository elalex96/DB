CREATE PROC [dbo].[p_FI_TransferFechaPresentacionGasto_Upd] 
--
@pIdTransferencia INT, 
@IdContrato       INT, 
@IdUsuario        INT
--@pGastosActualizados INT OUT
--
AS
     SET NOCOUNT ON;
     --DROP TABLE #tmpTemp;
     --DROP TABLE #Fechas;
     DECLARE @MesPresentacionCGI DATE, @FechaPago DATE, @FechaMayor DATE;
     DECLARE @pGastosActualizados INT;

     /**/

     CREATE TABLE #Fechas
     (Fecha DATE, 
      Tipo  INT
     );
     --
     CREATE TABLE #tmpTemp
     (IdRegistro              INT, 
      MesPresentacionCGI      DATE, 
      IdTransferencia         INT, 
      IdContrato              INT, 
      RegistroMesPresentacion DATE
     );

     /**/

     SELECT @MesPresentacionCGI = '1999-01-01',--C.MesPresentacionCGI, 
            @FechaPago = DATEFROMPARTS(YEAR(T.FechaPago), MONTH(T.FechaPago), 1)
     FROM dbo.CO_Contrato C
          JOIN dbo.FI_Transfer T ON T.IdContrato = C.IdContrato
     WHERE C.IdContrato = @IdContrato
           AND T.IdTransferencia = @pIdTransferencia;
     --
     INSERT INTO #Fechas
     (Fecha, 
      Tipo
     )
     VALUES
     (@MesPresentacionCGI, 
      1
     );
     INSERT INTO #Fechas
     (Fecha, 
      Tipo
     )
     VALUES
     (@FechaPago, 
      2
     );
     --
     SELECT @FechaMayor = MAX(Fecha)
     FROM #Fechas;

     /**/

     INSERT INTO #tmpTemp
            SELECT r.IdRegistro, 
                   MesPresentacion = c.MesPresentacionCGI, 
                   t.IdTransferencia, 
                   t.IdContrato, 
                   MesPresentacionActual = r.MesPresentacion
            FROM dbo.[FI_Transfer] t
                 LEFT JOIN dbo.FI_TransferFactura tf ON tf.IdTransfer = t.IdTransferencia
                 LEFT JOIN dbo.FI_Factura f ON f.IdFactura = tf.IdFactura
                 LEFT JOIN dbo.CO_Registro r ON r.IdFactura = f.IdFactura
                 LEFT JOIN dbo.CO_Contrato c ON c.IdContrato = t.IdContrato
            WHERE t.IdTransferencia = @pIdTransferencia
                  AND c.MesPresentacionCGI IS NOT NULL
                  AND t.IdContrato = @IdContrato
            --
            UNION 
            --
            SELECT r.IdRegistro, 
                   MesPresentacion = c.MesPresentacionCGI, 
                   t.IdTransferencia, 
                   t.IdContrato, 
                   MesPresentacionActual = r.MesPresentacion
            FROM dbo.[FI_Transfer] t
                 LEFT JOIN dbo.FI_TransferFactura tf ON tf.IdTransfer = t.IdTransferencia
                 LEFT JOIN dbo.FI_PedimentoComprobante pc ON pc.IdPedimentoComprobante = tf.IdPedimentoComprobante
                 LEFT JOIN dbo.CO_Registro r ON r.IdPedimentoComprobante = pc.IdPedimentoComprobante
                 LEFT JOIN dbo.CO_Contrato c ON c.IdContrato = t.IdContrato
            WHERE t.IdTransferencia = @pIdTransferencia
                  AND c.MesPresentacionCGI IS NOT NULL
                  AND t.IdContrato = @IdContrato
            --
            UNION 
            --
            SELECT r.IdRegistro, 
                   MesPresentacion = c.MesPresentacionCGI, 
                   t.IdTransferencia, 
                   t.IdContrato, 
                   MesPresentacionActual = r.MesPresentacion
            FROM dbo.[FI_Transfer] t
                 LEFT JOIN dbo.FI_Factura f ON f.IdFactura = t.IdFacturaPago
                 LEFT JOIN dbo.CO_Registro r ON r.IdFactura = f.IdFactura
                 LEFT JOIN dbo.CO_Contrato c ON c.IdContrato = t.IdContrato
            WHERE t.IdTransferencia = @pIdTransferencia
                  AND c.MesPresentacionCGI IS NOT NULL
                  AND t.IdContrato = @IdContrato;

     /**/

     SELECT @pGastosActualizados = COUNT(DISTINCT IdRegistro)
     FROM #tmpTemp;

     /**/

     UPDATE r
       SET 
           MesPresentacion = @FechaMayor
     FROM CO_Registro r
          JOIN #tmpTemp t ON t.IdRegistro = r.IdRegistro
     WHERE t.IdRegistro = r.IdRegistro;

     /**/

     SELECT @pGastosActualizados, 
            CONVERT(VARCHAR, @FechaMayor, 111);