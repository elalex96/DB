CREATE TABLE [dbo].[ML_AdincoMail] (
    [IdAdincoMail]      INT            IDENTITY (10000, 1) NOT NULL,
    [HostName]          NVARCHAR (250) NULL,
    [UserName]          NVARCHAR (250) NULL,
    [Password]          NVARCHAR (50)  NULL,
    [Port]              INT            NULL,
    [UseSsl]            BIT            NULL,
    [UltimoNumeroLeido] INT            NULL,
    [UltimaLectura]     DATETIME       NULL,
    CONSTRAINT [PK_AdincoMail] PRIMARY KEY CLUSTERED ([IdAdincoMail] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

