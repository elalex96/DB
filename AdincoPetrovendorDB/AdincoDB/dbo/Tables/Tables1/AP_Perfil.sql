CREATE TABLE [dbo].[AP_Perfil] (
    [IdPerfil]    INT            IDENTITY (1, 1) NOT NULL,
    [IdRol]       INT            NULL,
    [IdContrato]  INT            NULL,
    [Descripcion] NVARCHAR (MAX) NULL,
    [CreadoPor]   INT            NULL,
    CONSTRAINT [PK_AP_Perfil] PRIMARY KEY CLUSTERED ([IdPerfil] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_Perfil_AP_Rol] FOREIGN KEY ([IdRol]) REFERENCES [dbo].[AP_Rol] ([IdRol]),
    CONSTRAINT [FK_AP_Perfil_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);


GO
-- =============================================
-- Author:		Manuel
-- Create date: 
-- Description:	
-- =============================================
CREATE TRIGGER [dbo].[tr_AP_DescripcionPerfil] 
   ON  [dbo].[AP_Perfil] 
   AFTER INSERT, UPDATE
AS 

DECLARE @IdRol AS INT
DECLARE @IdContrato AS INT
DECLARE @AreaContractual AS NVARCHAR(MAX)
DECLARE @Contrato AS NVARCHAR(MAX)
DECLARE @Rol AS NVARCHAR(MAX)

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT @IdRol = IdRol FROM inserted
	SELECT @IdContrato = IdContrato  FROM inserted 

    SELECT @Rol = Rol FROM AP_Rol 
	WHERE IdRol  = @IdRol

	SELECT @AreaContractual  = AC.NombreAreaContractual 
	FROM CO_AreaContractual AC
	JOIN CO_Contrato C
	ON AC.IdAreaContractual = C.IdAreaContractual
	WHERE C.IdContrato=@IdContrato

	SELECT @Contrato =C.NumeroContrato  FROM CO_Contrato C WHERE C.IdContrato =@IdContrato 
	

	-- Insert statements for trigger here
	--SELECT @DESCRIPCION = R.Rol + ' de ' + AC.AreaContractual FROM Perfil P 
	--JOIN Rol R 
	--ON p.RolID = r.RolID

	--JOIN AreaContractual AC
	--ON AC.AreaContractualID = P.AreaContractualID 
	--WHERE R.RolID = @ROLID AND AC.AreaContractualID = @AREACONTRACTUALID

	UPDATE AP_Perfil  SET Descripcion = @Rol + ' del Contrato ' + @Contrato +' ['+ @AreaContractual +']'
	FROM AP_Perfil P JOIN inserted ON P.IdPerfil  = inserted.IdPerfil 

END
