-- =============================================
-- Author:		Manuel Cruz
-- Create date: 27-06-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_ValidaVolumenPorMes]
    @IdContrato INT,
    @IdUsuario INT,
    @MesReporte DATE,
	@Activo BIT,
	@Id INT
AS
BEGIN
    SET NOCOUNT ON;

	IF(@Activo = 1)--Registro normal activo se verifica 
	BEGIN
    IF EXISTS (   SELECT *
                    FROM dbo.PR_VolumenMensualProduccionPetroleo
                   WHERE IdContrato = @IdContrato
                     AND MesReporte = @MesReporte
					 AND Activo = 1
					 AND IdReporteVolumenesProduccionPetroleo <> @Id)
    BEGIN
        SELECT 'true' AS Existe,
               1 AS Editar;
    END;
    ELSE
    BEGIN
        SELECT 'false' AS Existe,
               0 AS Editar;
    END;
	END
	ELSE
	BEGIN -- Si el registro nuevo no esta activo no se hace validación  ya que va desactivado
	  SELECT 'false' AS Existe,
               0 AS Editar;
	END;
END;
