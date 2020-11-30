-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2018
-- Description:	Valida que los km que se insertaran o modificaran la suma de todos, no rebase el total del area contractual
-- =============================================
CREATE PROCEDURE sp_CO_ValidaInsertKMPropietario
	@IdContrato INT,
	@IdUsuario INT,
	@idPropietario INT,
	@RFC NVARCHAR(13),
	@NombrePropietario NVARCHAR(100),
	@KM Float
AS
BEGIN
	SET NOCOUNT ON;
		
	 DECLARE 
            @error nvarchar(Max)='',
            @totalkmPropietaSum float,
            @totalSuperficieAreaC float,
			@idAreaContractual INT;

			SELECT @idAreaContractual=IdAreaContractual FROM dbo.CO_Contrato
			WHERE IdContrato=@IdContrato

        SELECT @totalkmPropietaSum = ISNULL(SUM(KM2), 0)
        FROM CO_PropietariosAreaContractual r
        WHERE r.IdAreaContractual =@idAreaContractual
              AND r.IdPropietario <> @idPropietario;

        SELECT @totalSuperficieAreaC=ISNULL(AC.SuperficieKm2, 0)
		 FROM dbo.CO_Contrato C
		JOIN dbo.CO_AreaContractual AC on AC.IdAreaContractual = C.IdAreaContractual
			WHERE IdContrato=@IdContrato;

        IF @totalkmPropietaSum + ISNULL(@KM, 0) > @totalSuperficieAreaC
        BEGIN
		DECLARE @CatidadPosible INT=(ISNULL(@totalSuperficieAreaC, 0) - ISNULL(@totalkmPropietaSum, 0));

            SET @error='No es posible Insertar la cantidad de '+ LTRIM( @KM) +' KM2, ya que la sumatoria excede el total de la superficie del area contractual.Los Km2 disponibles a capturar son '+ LTRIM(@CatidadPosible);
        END;
		

	 Select @error;
		

END
