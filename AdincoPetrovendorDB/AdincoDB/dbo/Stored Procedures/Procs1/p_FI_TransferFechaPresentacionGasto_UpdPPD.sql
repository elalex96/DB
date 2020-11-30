-- =============================================
-- Author:		Manuel Cruz
-- Create date: 19-08-2019
-- Description:	
-- =============================================
CREATE PROCEDURE [p_FI_TransferFechaPresentacionGasto_UpdPPD]
-- Add the parameters for the stored procedure here
@pIdTransferencia INT, 
@IdContrato       INT, 
@IdUsuario        INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @MesPresentacionCGI DATE, @FechaPago DATE, @FechaMayor DATE;
         DECLARE @pGastosActualizados INT;
         -- Insert statements for procedure here
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
                     JOIN dbo.FI_TransferFactura tf ON tf.IdTransfer = t.IdTransferencia
                     JOIN dbo.FI_Factura f ON f.IdFactura = tf.IdFactura
                     JOIN dbo.FI_ComplementoDePago cp ON f.IdFactura = cp.IdFactura
                     JOIN dbo.FI_CPDocRelacionado cpdr ON cpdr.IdComplementoDePago = cp.IdComplementoDePago
                     JOIN dbo.FI_Factura fcpdr ON cpdr.IdDocumento = fcpdr.UUID
                     JOIN dbo.CO_Registro r ON r.IdFactura = fcpdr.IdFactura
                     JOIN dbo.CO_Contrato c ON c.IdContrato = t.IdContrato
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
     END;