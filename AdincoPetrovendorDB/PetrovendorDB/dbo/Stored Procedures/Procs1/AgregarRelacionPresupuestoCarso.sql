--USE [Petrovendor]
--GO
--DROP PROC IF EXISTS AgregarRelacionPresupuestoCarso
--GO
--/****** Object:  StoredProcedure [dbo].[SP_PP_InsCotizacionC]    Script Date: 08/01/2025 01:34:16 p. m. ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
-- =============================================
-- Author:		DANIEL AC
-- Create date: <17-02-2025>
-- Description:	Se valida se permita ingresar la misma LineaAx, siempre y cuando sea sea en un contrato que no tenga esa clave 
-- ======================
CREATE PROCEDURE [dbo].[AgregarRelacionPresupuestoCarso]
@IdContrato INT,
@IdPresupuesto INT,
@PresupuestoAx NVARCHAR(MAX),
@IdUsuario INT
AS
BEGIN
    DECLARE @Anio INT
	DECLARE @ExisteAnioLineaEnContrato INT

    SELECT @Anio = a.Anio
    FROM Adinco.dbo.CO_Presupuesto p (nolock)
        INNER JOIN Adinco.dbo.CO_AnioContractual a  (nolock)
            ON  p.IdAnioContractual = a.IdAnioContractual
    WHERE a.IdContrato = @IdContrato
          AND p.IdPresupuesto = @IdPresupuesto

	SELECT  @ExisteAnioLineaEnContrato = COUNT(1)
    FROM Adinco.dbo.CO_Presupuesto p (nolock)
        INNER JOIN Adinco.dbo.CO_AnioContractual a (nolock)
            ON  p.IdAnioContractual = a.IdAnioContractual
		INNER JOIN Petrovendor..AX_AnioContractual ACAX (nolock)
			ON P.IdPresupuesto = ACAX.IdPresupuesto
    WHERE A.IdContrato = @IdContrato
		  AND ACAX.AnioLinea = @PresupuestoAx

    IF ISNULL(@ExisteAnioLineaEnContrato,0)>0
    BEGIN
        RAISERROR('Clave de presupuesto de Ax ya registrado en este contrato', 16, 1)
    END
    ELSE
    BEGIN
        INSERT INTO dbo.AX_AnioContractual (AnioLinea, AnioReal, IdPresupuesto, CreadoPor, FechaCreacion)
        VALUES
        (   @PresupuestoAx, -- AnioLinea - nvarchar(100)
            @Anio,          -- AnioReal - int
            @IdPresupuesto, -- IdPresupuesto - int
            @IdUsuario, GETDATE())
    END
END
