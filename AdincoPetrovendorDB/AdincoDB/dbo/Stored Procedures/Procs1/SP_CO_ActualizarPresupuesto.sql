-- =============================================
-- Author:		Marcos Garcia
-- Create date: 22-01-2020
-- Description:	Actualiza en Co_Presupuesto mediante IdPresupuesto
-- =============================================
-- Alter date: 12-02-2020
-- Description:	Update Activo por Actual
-- =============================================

CREATE PROCEDURE [dbo].[SP_CO_ActualizarPresupuesto] 
--  the parameters for the stored procedure here 
@IdPresupuesto     INT, 
@IdPresupuestoCNH  NVARCHAR(50), 
@Activo            BIT, 
@ActivoProcura     BIT, 
@InicioPresupuesto DATE, 
@FinPresupuesto    DATE, 
@IdUsuario         INT, 
@IdContrato        INT
AS
     BEGIN
         DECLARE @DateInicio DATE, @DateFin DATE;
         SET @DateInicio = (CASE
                                WHEN @InicioPresupuesto = '01-01-1900'
                                THEN NULL
                                ELSE @InicioPresupuesto
                            END);
         SET @DateFin = (CASE
                             WHEN @FinPresupuesto = '01-01-1900'
                             THEN NULL
                             ELSE @FinPresupuesto
                         END);
         BEGIN
             UPDATE dbo.CO_Presupuesto
               SET 
                   IdPresupuestoCNH = @IdPresupuestoCNH, 
                   Actual = @Activo, 
                   ActivoProcura = @ActivoProcura, 
                   InicioPresupuesto = @DateInicio, 
                   FinPresupuesto = @DateFin, 
                   ModificadoPor = @IdUsuario, 
                   ModificadoEl = GETDATE()
             WHERE IdPresupuesto = @IdPresupuesto;
         END;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;